<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Exception;

class DynamicReportService
{
    protected $reportFilterService;

    public function __construct()
    {
        $this->reportFilterService = new ReportFilterService();
    }
    /**
     * Get complete laporan configuration by laporan code
     *
     * @param string $laporanCode
     * @return array|null
     */
    public function getLaporanConfiguration(string $laporanCode): ?array
    {
        try {
            // Get base laporan config
            $config = DB::selectOne("
                SELECT * FROM DBREPORTCONFIG
                WHERE KODEREPORT = ?
            ", [$laporanCode]);

            if (!$config) {
                return null;
            }

            // Get laporan headers
            $headers = DB::select("
                SELECT * FROM DBREPORTHEADER
                WHERE KODEREPORT = ?
            ", [$laporanCode]);

            // Get laporan columns
            $columns = DB::select("
                SELECT * FROM DBREPORTCOLUMN
                WHERE KODEREPORT = ?
                ORDER BY SORT_ORDER
            ", [$laporanCode]);

            // Get laporan groups (if any)
            $groups = DB::select("
                SELECT * FROM DBREPORTGROUP
                WHERE KODEREPORT = ?
                ORDER BY SORT_ORDER
            ", [$laporanCode]);

            // Get laporan filters (NEW)
            $filters = $this->reportFilterService->getReportFilters($laporanCode);

            return [
                'config' => $config,
                'headers' => $headers,
                'columns' => $columns,
                'groups' => $groups,
                'filters' => $filters
            ];

        } catch (Exception $e) {
            Log::error('DynamicReportService - getLaporanConfiguration error', [
                'laporanCode' => $laporanCode,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Execute laporan query based on configuration
     *
     * @param string $laporanCode
     * @param array $parameters
     * @return array
     */
    public function executeLaporan(string $laporanCode, array $parameters = []): array
    {
        try {
            $laporanConfig = $this->getLaporanConfiguration($laporanCode);

            if (!$laporanConfig || !$laporanConfig['config']) {
                throw new Exception("Laporan configuration not found for code: {$laporanCode}");
            }

            $config = $laporanConfig['config'];
            $columns = $laporanConfig['columns'];
            $filters = $laporanConfig['filters'] ?? [];

            // Process and validate filter parameters
            $processedFilters = $this->processFilterParameters($filters, $parameters);

            // Build query based on configuration with filters
            $query = $this->buildLaporanQuery($config, $parameters, $processedFilters);

            // Execute query with filter parameters and where condition parameters
            $whereParameters = $this->getWhereConditionParameters($config, $parameters);
            $filterParameters = $this->getFilterParameterValues($processedFilters);
            $allParameters = array_merge($whereParameters, $filterParameters);
            $rawData = DB::select($query, $allParameters);

            // Process data according to column configurations
            $processedData = $this->processLaporanData($rawData, $columns);

            return [
                'success' => true,
                'data' => $processedData,
                'config' => $laporanConfig,
                'total' => count($processedData)
            ];

        } catch (Exception $e) {
            Log::error('DynamicReportService - executeLaporan error', [
                'laporanCode' => $laporanCode,
                'parameters' => $parameters,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'data' => [],
                'config' => null,
                'total' => 0
            ];
        }
    }

    /**
     * Build SQL query based on laporan configuration with filter support
     *
     * @param object $config
     * @param array $parameters
     * @param array $filters - Applied filter values
     * @return string
     */
    private function buildLaporanQuery($config, array $parameters, array $filters = []): string
    {
        // Check if stored procedure is specified
        if (!empty($config->STOREDPROC)) {
            // Use stored procedure
            $paramPlaceholders = str_repeat('?,', count($parameters));
            $paramPlaceholders = rtrim($paramPlaceholders, ',');
            return "EXEC {$config->STOREDPROC} {$paramPlaceholders}";
        }

        // Parse CONFIG_JSON for data source
        $configJson = json_decode($config->CONFIG_JSON, true);
        if ($configJson) {
            // Use view/table from dataSource in JSON config
            if (!empty($configJson['dataSource'])) {
                // Build SELECT clause with fields if specified
                $selectClause = "SELECT ";
                if (!empty($configJson['fields']) && is_array($configJson['fields'])) {
                    $fieldList = [];
                    foreach ($configJson['fields'] as $alias => $expression) {
                        $fieldList[] = $expression;
                    }
                    $selectClause .= implode(', ', $fieldList);
                } else {
                    $selectClause .= "*";
                }

                $baseQuery = $selectClause . " FROM {$configJson['dataSource']}";

                // Apply whereConditions from config if specified
                $whereConditions = [];
                if (!empty($configJson['whereConditions']) && is_array($configJson['whereConditions'])) {
                    foreach ($configJson['whereConditions'] as $condition) {
                        if (is_string($condition)) {
                            // Simple condition string
                            $whereConditions[] = $condition;
                        } elseif (is_array($condition) && count($condition) >= 2) {
                            // Array format: [condition, paramNames]
                            $whereConditions[] = $condition[0];
                        }
                    }
                }

                // Apply filters to query
                $filterWhere = $this->buildFilterWhereClause($filters);
                if ($filterWhere) {
                    $whereConditions[] = $filterWhere;
                }

                if (!empty($whereConditions)) {
                    $baseQuery .= " WHERE " . implode(' AND ', $whereConditions);
                }

                $orderBy = !empty($configJson['orderBy']) ? " ORDER BY {$configJson['orderBy']}" : '';
                return $baseQuery . $orderBy;
            }
        }

        throw new Exception('No valid data source found in report configuration');
    }

    /**
     * Process laporan data according to column configurations
     *
     * @param array $rawData
     * @param array $columns
     * @return array
     */
    private function processLaporanData(array $rawData, array $columns): array
    {
        if (empty($rawData)) {
            return [];
        }

        $processedData = [];

        foreach ($rawData as $row) {
            $processedRow = [];
            $rowArray = (array) $row;

            foreach ($columns as $column) {
                $fieldName = $column->COLUMN_NAME;
                $rawValue = $rowArray[$fieldName] ?? null;

                // Apply formatting based on column configuration
                $processedValue = $this->formatColumnValue(
                    $rawValue,
                    $column->DATA_TYPE ?? 'VARCHAR',
                    $column->FORMAT_MASK ?? null
                );

                // Use column label or field name as key
                $displayKey = $column->COLUMN_LABEL ?: $fieldName;
                $processedRow[$fieldName] = [
                    'value' => $processedValue,
                    'display' => $displayKey,
                    'alignment' => $column->ALIGNMENT ?? 'left',
                    'width' => $column->WIDTH ?? null,
                    'dataType' => $column->DATA_TYPE ?? 'VARCHAR'
                ];
            }

            $processedData[] = $processedRow;
        }

        return $processedData;
    }

    /**
     * Format column value based on data type and format mask
     *
     * @param mixed $value
     * @param string $dataType
     * @param string|null $formatMask
     * @return string
     */
    private function formatColumnValue($value, string $dataType, ?string $formatMask): string
    {
        if ($value === null) {
            return '';
        }

        // Handle encoding for text fields
        if (in_array(strtoupper($dataType), ['VARCHAR', 'CHAR', 'TEXT', 'NVARCHAR'])) {
            $value = mb_convert_encoding($value, 'UTF-8', 'UTF-8');
        }

        // Apply format mask if specified
        if ($formatMask) {
            switch (strtoupper($dataType)) {
                case 'DECIMAL':
                case 'NUMERIC':
                case 'MONEY':
                    if (is_numeric($value)) {
                        return number_format((float)$value, $this->getDecimalPlaces($formatMask));
                    }
                    break;

                case 'DATETIME':
                case 'DATE':
                    try {
                        $date = new \DateTime($value);
                        return $date->format($this->convertFormatMask($formatMask));
                    } catch (Exception $e) {
                        // Return original value if date conversion fails
                    }
                    break;
            }
        }

        return (string) $value;
    }

    /**
     * Get decimal places from format mask
     *
     * @param string $formatMask
     * @return int
     */
    private function getDecimalPlaces(string $formatMask): int
    {
        // Extract decimal places from format like "#,##0.00" or "0.000"
        if (preg_match('/\.(\d+)/', $formatMask, $matches)) {
            return strlen($matches[1]);
        }
        return 0;
    }

    /**
     * Convert database format mask to PHP date format
     *
     * @param string $formatMask
     * @return string
     */
    private function convertFormatMask(string $formatMask): string
    {
        // Common database date formats to PHP formats
        $conversions = [
            'DD/MM/YYYY' => 'd/m/Y',
            'DD-MM-YYYY' => 'd-m-Y',
            'MM/DD/YYYY' => 'm/d/Y',
            'YYYY-MM-DD' => 'Y-m-d',
            'DD/MM/YY' => 'd/m/y',
        ];

        return $conversions[$formatMask] ?? 'Y-m-d';
    }

    /**
     * Get available laporan list
     *
     * @return array
     */
    public function getAvailableLaporan(): array
    {
        try {
            $reports = DB::select("
                SELECT KODEREPORT, CONFIG_TYPE, CONFIG_JSON, IS_ACTIVE
                FROM DBREPORTCONFIG
                WHERE IS_ACTIVE = 1
                ORDER BY CONFIG_TYPE, KODEREPORT
            ");

            return array_map(function($report) {
                $configJson = json_decode($report->CONFIG_JSON, true);
                return [
                    'code' => $report->KODEREPORT,
                    'name' => $configJson['title'] ?? $report->KODEREPORT,
                    'description' => $configJson['description'] ?? '',
                    'category' => $report->CONFIG_TYPE
                ];
            }, $reports);

        } catch (Exception $e) {
            Log::error('DynamicReportService - getAvailableLaporan error', [
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }

    /**
     * Get laporan column definitions for frontend
     *
     * @param string $reportCode
     * @return array
     */
    public function getLaporanColumns(string $laporanCode): array
    {
        try {
            $columns = DB::select("
                SELECT COLUMN_NAME, COLUMN_LABEL, WIDTH, ALIGNMENT, DATA_TYPE, FORMAT_MASK, SORT_ORDER, IS_VISIBLE
                FROM DBREPORTCOLUMN
                WHERE KODEREPORT = ? AND IS_VISIBLE = 1
                ORDER BY SORT_ORDER
            ", [$laporanCode]);

            return array_map(function($column) {
                return [
                    'key' => $column->COLUMN_NAME,
                    'label' => $column->COLUMN_LABEL ?: $column->COLUMN_NAME,
                    'width' => $column->WIDTH . 'px',
                    'align' => strtolower($column->ALIGNMENT ?? 'left'),
                    'dataType' => $column->DATA_TYPE ?? 'VARCHAR',
                    'format' => $column->FORMAT_MASK
                ];
            }, $columns);

        } catch (Exception $e) {
            Log::error('DynamicReportService - getLaporanColumns error', [
                'laporanCode' => $laporanCode,
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }

    /**
     * Build WHERE clause from filter parameters
     *
     * @param array $filters
     * @return string
     */
    private function buildFilterWhereClause(array $filters): string
    {
        $conditions = [];

        foreach ($filters as $filter) {
            if (!isset($filter['value']) || $filter['value'] === null || $filter['value'] === '') {
                continue;
            }

            $fieldName = $filter['fieldName'];
            $filterType = $filter['filterType'];
            $value = $filter['value'];

            switch ($filterType) {
                case 'date':
                    $conditions[] = "{$fieldName} = ?";
                    break;

                case 'daterange':
                    if (isset($value['start']) && isset($value['end'])) {
                        $conditions[] = "{$fieldName} BETWEEN ? AND ?";
                    } elseif (isset($value['start'])) {
                        $conditions[] = "{$fieldName} >= ?";
                    } elseif (isset($value['end'])) {
                        $conditions[] = "{$fieldName} <= ?";
                    }
                    break;

                case 'select':
                case 'radio':
                    $conditions[] = "{$fieldName} = ?";
                    break;

                case 'text':
                case 'lookup':
                    if (isset($filter['filterConfig']['exactMatch']) && $filter['filterConfig']['exactMatch']) {
                        $conditions[] = "{$fieldName} = ?";
                    } else {
                        $conditions[] = "{$fieldName} LIKE ?";
                    }
                    break;

                case 'checkbox':
                    if ($value) {
                        $conditions[] = "{$fieldName} = 1";
                    } else {
                        $conditions[] = "({$fieldName} = 0 OR {$fieldName} IS NULL)";
                    }
                    break;

                case 'number':
                    if (isset($value['operator'])) {
                        $operator = $value['operator']; // =, >, <, >=, <=
                        $conditions[] = "{$fieldName} {$operator} ?";
                    } else {
                        $conditions[] = "{$fieldName} = ?";
                    }
                    break;
            }
        }

        return implode(' AND ', $conditions);
    }

    /**
     * Process filter parameters from request
     *
     * @param array $filterConfigs
     * @param array $requestParameters
     * @return array
     */
    private function processFilterParameters(array $filterConfigs, array $requestParameters): array
    {
        $processedFilters = [];

        foreach ($filterConfigs as $filterConfig) {
            $filterName = $filterConfig['filterName'];
            $fieldName = $filterConfig['fieldName'];
            $filterType = $filterConfig['filterType'];

            // Check if filter value exists in request
            if (!array_key_exists($filterName, $requestParameters)) {
                // Use default value if available
                if (isset($filterConfig['defaultValue'])) {
                    $value = $filterConfig['defaultValue'];
                } else {
                    continue;
                }
            } else {
                $value = $requestParameters[$filterName];
            }

            // Validate and process value based on filter type
            $processedValue = $this->validateAndProcessFilterValue($value, $filterType, $filterConfig);

            if ($processedValue !== null) {
                $processedFilters[] = [
                    'filterName' => $filterName,
                    'fieldName' => $fieldName,
                    'filterType' => $filterType,
                    'value' => $processedValue,
                    'filterConfig' => $filterConfig['filterConfig'] ?? []
                ];
            }
        }

        return $processedFilters;
    }

    /**
     * Validate and process filter value based on filter type
     *
     * @param mixed $value
     * @param string $filterType
     * @param array $filterConfig
     * @return mixed
     */
    private function validateAndProcessFilterValue($value, string $filterType, array $filterConfig)
    {
        switch ($filterType) {
            case 'date':
                try {
                    return date('Y-m-d', strtotime($value));
                } catch (Exception $e) {
                    return null;
                }

            case 'daterange':
                if (is_array($value)) {
                    $processed = [];
                    if (isset($value['start'])) {
                        try {
                            $processed['start'] = date('Y-m-d', strtotime($value['start']));
                        } catch (Exception $e) {
                            // Invalid start date
                        }
                    }
                    if (isset($value['end'])) {
                        try {
                            $processed['end'] = date('Y-m-d', strtotime($value['end']));
                        } catch (Exception $e) {
                            // Invalid end date
                        }
                    }
                    return !empty($processed) ? $processed : null;
                }
                return null;

            case 'select':
            case 'radio':
                return $value;

            case 'text':
            case 'lookup':
                if (isset($filterConfig['filterConfig']['exactMatch']) && $filterConfig['filterConfig']['exactMatch']) {
                    return $value;
                } else {
                    return "%{$value}%"; // Add wildcards for LIKE query
                }

            case 'checkbox':
                return (bool) $value;

            case 'number':
                if (is_array($value) && isset($value['value'])) {
                    return [
                        'operator' => $value['operator'] ?? '=',
                        'value' => (float) $value['value']
                    ];
                } else {
                    return (float) $value;
                }

            default:
                return $value;
        }
    }

    /**
     * Get parameter values from where conditions for SQL binding
     *
     * @param object $config
     * @param array $parameters
     * @return array
     */
    private function getWhereConditionParameters($config, array $parameters): array
    {
        $whereParams = [];

        $configJson = json_decode($config->CONFIG_JSON, true);
        if ($configJson && !empty($configJson['whereConditions'])) {
            foreach ($configJson['whereConditions'] as $condition) {
                if (is_array($condition) && count($condition) >= 2) {
                    // Array format: [condition, paramNames]
                    $paramNames = $condition[1];
                    if (is_array($paramNames)) {
                        foreach ($paramNames as $paramName) {
                            if (isset($parameters[$paramName])) {
                                $whereParams[] = $parameters[$paramName];
                            }
                        }
                    }
                }
            }
        }

        return $whereParams;
    }

    /**
     * Get parameter values from processed filters for SQL binding
     *
     * @param array $processedFilters
     * @return array
     */
    private function getFilterParameterValues(array $processedFilters): array
    {
        $values = [];

        foreach ($processedFilters as $filter) {
            $filterType = $filter['filterType'];
            $value = $filter['value'];

            switch ($filterType) {
                case 'date':
                case 'select':
                case 'radio':
                case 'text':
                case 'lookup':
                    $values[] = $value;
                    break;

                case 'daterange':
                    if (isset($value['start'])) {
                        $values[] = $value['start'];
                    }
                    if (isset($value['end'])) {
                        $values[] = $value['end'];
                    }
                    break;

                case 'number':
                    if (is_array($value)) {
                        $values[] = $value['value'];
                    } else {
                        $values[] = $value;
                    }
                    break;

                // checkbox doesn't add parameters as it's handled in WHERE clause directly
                case 'checkbox':
                    break;
            }
        }

        return $values;
    }

    /**
     * Get filter configurations for a report (public method)
     *
     * @param string $laporanCode
     * @return array
     */
    public function getReportFilters(string $laporanCode): array
    {
        return $this->reportFilterService->getReportFilters($laporanCode);
    }

    /**
     * Get filter options for a specific filter
     *
     * @param string $laporanCode
     * @param string $filterName
     * @param array $parameters
     * @return array
     */
    public function getFilterOptions(string $laporanCode, string $filterName, array $parameters = []): array
    {
        try {
            $filters = $this->getReportFilters($laporanCode);

            foreach ($filters as $filter) {
                if ($filter['filterName'] === $filterName) {
                    if (isset($filter['optionsSource'])) {
                        return $this->reportFilterService->getFilterOptions($filter['optionsSource'], $parameters);
                    }
                    break;
                }
            }

            return [];

        } catch (Exception $e) {
            Log::error('DynamicReportService - getFilterOptions error', [
                'laporanCode' => $laporanCode,
                'filterName' => $filterName,
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }
}