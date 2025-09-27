<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Exception;

class ReportFilterService
{
    /**
     * Get all filter configurations for a specific report
     *
     * @param string $reportCode
     * @return array
     */
    public function getReportFilters(string $reportCode): array
    {
        try {
            $filters = DB::select("
                SELECT * FROM DBREPORTFILTER
                WHERE KODEREPORT = ? AND IS_VISIBLE = 1
                ORDER BY SORT_ORDER
            ", [$reportCode]);

            return array_map(function($filter) {
                return $this->processFilterConfig($filter);
            }, $filters);

        } catch (Exception $e) {
            Log::error('ReportFilterService - getReportFilters error', [
                'reportCode' => $reportCode,
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }

    /**
     * Get filter configuration by ID
     *
     * @param int $filterId
     * @return array|null
     */
    public function getFilterById(int $filterId): ?array
    {
        try {
            $filter = DB::selectOne("
                SELECT * FROM DBREPORTFILTER
                WHERE ID = ?
            ", [$filterId]);

            return $filter ? $this->processFilterConfig($filter) : null;

        } catch (Exception $e) {
            Log::error('ReportFilterService - getFilterById error', [
                'filterId' => $filterId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Create new filter configuration
     *
     * @param array $filterData
     * @return array
     */
    public function createFilter(array $filterData): array
    {
        try {
            // Validate required fields
            $this->validateFilterData($filterData);

            $filterId = DB::table('DBREPORTFILTER')->insertGetId([
                'KODEREPORT' => $filterData['reportCode'],
                'FILTER_NAME' => $filterData['filterName'],
                'FILTER_TYPE' => $filterData['filterType'],
                'FILTER_SOURCE' => $filterData['fieldName'],
                'LABEL' => $filterData['label'] ?? null,
                'DEFAULT_VALUE' => $filterData['defaultValue'] ?? null,
                'OPTIONS_SOURCE' => $filterData['optionsSource'] ?? null,
                'IS_REQUIRED' => $filterData['isRequired'] ?? false,
                'SORT_ORDER' => $filterData['sortOrder'] ?? 1,
                'IS_VISIBLE' => $filterData['isVisible'] ?? true,
                'VALIDATION_RULES' => $filterData['validationRules'] ?? null,
                'FILTER_CONFIG' => $filterData['filterConfig'] ?? null,
                'CREATED_DATE' => now(),
                'MODIFIED_DATE' => now()
            ]);

            return [
                'success' => true,
                'filterId' => $filterId,
                'message' => 'Filter created successfully'
            ];

        } catch (Exception $e) {
            Log::error('ReportFilterService - createFilter error', [
                'filterData' => $filterData,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Update existing filter configuration
     *
     * @param int $filterId
     * @param array $filterData
     * @return array
     */
    public function updateFilter(int $filterId, array $filterData): array
    {
        try {
            // Check if filter exists
            $existingFilter = $this->getFilterById($filterId);
            if (!$existingFilter) {
                return [
                    'success' => false,
                    'error' => 'Filter not found'
                ];
            }

            // Validate update data
            $this->validateFilterData($filterData, true);

            $updateData = [
                'MODIFIED_DATE' => now()
            ];

            // Only update provided fields
            $updatableFields = [
                'filterName' => 'FILTER_NAME',
                'filterType' => 'FILTER_TYPE',
                'fieldName' => 'FILTER_SOURCE',
                'label' => 'LABEL',
                'defaultValue' => 'DEFAULT_VALUE',
                'optionsSource' => 'OPTIONS_SOURCE',
                'isRequired' => 'IS_REQUIRED',
                'sortOrder' => 'SORT_ORDER',
                'isVisible' => 'IS_VISIBLE',
                'validationRules' => 'VALIDATION_RULES',
                'filterConfig' => 'FILTER_CONFIG'
            ];

            foreach ($updatableFields as $inputField => $dbField) {
                if (array_key_exists($inputField, $filterData)) {
                    $updateData[$dbField] = $filterData[$inputField];
                }
            }

            DB::table('DBREPORTFILTER')
                ->where('ID', $filterId)
                ->update($updateData);

            return [
                'success' => true,
                'message' => 'Filter updated successfully'
            ];

        } catch (Exception $e) {
            Log::error('ReportFilterService - updateFilter error', [
                'filterId' => $filterId,
                'filterData' => $filterData,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Delete filter configuration
     *
     * @param int $filterId
     * @return array
     */
    public function deleteFilter(int $filterId): array
    {
        try {
            $deleted = DB::table('DBREPORTFILTER')
                ->where('ID', $filterId)
                ->delete();

            if ($deleted) {
                return [
                    'success' => true,
                    'message' => 'Filter deleted successfully'
                ];
            } else {
                return [
                    'success' => false,
                    'error' => 'Filter not found'
                ];
            }

        } catch (Exception $e) {
            Log::error('ReportFilterService - deleteFilter error', [
                'filterId' => $filterId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Get filter options from specified source
     *
     * @param string $optionsSource
     * @param array $parameters
     * @return array
     */
    public function getFilterOptions(string $optionsSource, array $parameters = []): array
    {
        try {
            // Check if options source is JSON array
            if (str_starts_with(trim($optionsSource), '[')) {
                return json_decode($optionsSource, true) ?? [];
            }

            // Check if options source is a table/view query
            if (str_contains($optionsSource, 'SELECT') || !str_contains($optionsSource, ' ')) {
                // If it's a simple table name, create basic SELECT query
                if (!str_contains($optionsSource, 'SELECT')) {
                    $query = "SELECT * FROM {$optionsSource} ORDER BY 1";
                } else {
                    $query = $optionsSource;
                }

                $results = DB::select($query, array_values($parameters));

                return array_map(function($item) {
                    return (array) $item;
                }, $results);
            }

            return [];

        } catch (Exception $e) {
            Log::error('ReportFilterService - getFilterOptions error', [
                'optionsSource' => $optionsSource,
                'parameters' => $parameters,
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }

    /**
     * Process filter configuration for frontend consumption
     *
     * @param object $filter
     * @return array
     */
    private function processFilterConfig($filter): array
    {
        $processedFilter = [
            'id' => $filter->ID,
            'reportCode' => $filter->KODEREPORT,
            'filterName' => $filter->FILTER_NAME,
            'filterType' => $filter->FILTER_TYPE,
            'fieldName' => $filter->FILTER_SOURCE,
            'label' => $filter->LABEL ?: $filter->FILTER_NAME,
            'defaultValue' => $filter->DEFAULT_VALUE,
            'isRequired' => (bool) $filter->IS_REQUIRED,
            'sortOrder' => $filter->SORT_ORDER,
            'isVisible' => (bool) $filter->IS_VISIBLE
        ];

        // Parse JSON fields
        if ($filter->OPTIONS_SOURCE) {
            $processedFilter['optionsSource'] = $filter->OPTIONS_SOURCE;
        }

        if ($filter->VALIDATION_RULES) {
            $processedFilter['validationRules'] = json_decode($filter->VALIDATION_RULES, true) ?? [];
        }

        if ($filter->FILTER_CONFIG) {
            $processedFilter['filterConfig'] = json_decode($filter->FILTER_CONFIG, true) ?? [];
        }

        return $processedFilter;
    }

    /**
     * Validate filter data
     *
     * @param array $filterData
     * @param bool $isUpdate
     * @throws Exception
     */
    private function validateFilterData(array $filterData, bool $isUpdate = false): void
    {
        $requiredFields = ['reportCode', 'filterName', 'filterType', 'fieldName'];

        if (!$isUpdate) {
            foreach ($requiredFields as $field) {
                if (!isset($filterData[$field]) || empty($filterData[$field])) {
                    throw new Exception("Field '{$field}' is required");
                }
            }
        }

        // Validate filter type
        $validFilterTypes = ['date', 'daterange', 'select', 'text', 'checkbox', 'radio', 'lookup', 'number'];
        if (isset($filterData['filterType']) && !in_array($filterData['filterType'], $validFilterTypes)) {
            throw new Exception("Invalid filter type. Must be one of: " . implode(', ', $validFilterTypes));
        }

        // Validate JSON fields
        if (isset($filterData['validationRules']) && is_string($filterData['validationRules'])) {
            $decoded = json_decode($filterData['validationRules'], true);
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception("Invalid JSON format in validationRules");
            }
        }

        if (isset($filterData['filterConfig']) && is_string($filterData['filterConfig'])) {
            $decoded = json_decode($filterData['filterConfig'], true);
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception("Invalid JSON format in filterConfig");
            }
        }
    }

    /**
     * Bulk create filter configurations for a report
     *
     * @param string $reportCode
     * @param array $filtersData
     * @return array
     */
    public function bulkCreateFilters(string $reportCode, array $filtersData): array
    {
        try {
            $createdFilters = [];
            $errors = [];

            DB::beginTransaction();

            foreach ($filtersData as $index => $filterData) {
                $filterData['reportCode'] = $reportCode;
                $result = $this->createFilter($filterData);

                if ($result['success']) {
                    $createdFilters[] = $result['filterId'];
                } else {
                    $errors[] = "Filter {$index}: " . $result['error'];
                }
            }

            if (empty($errors)) {
                DB::commit();
                return [
                    'success' => true,
                    'createdFilters' => $createdFilters,
                    'message' => 'All filters created successfully'
                ];
            } else {
                DB::rollBack();
                return [
                    'success' => false,
                    'errors' => $errors
                ];
            }

        } catch (Exception $e) {
            DB::rollBack();
            Log::error('ReportFilterService - bulkCreateFilters error', [
                'reportCode' => $reportCode,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}