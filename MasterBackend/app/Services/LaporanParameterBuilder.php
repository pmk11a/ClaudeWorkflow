<?php

namespace App\Services;

use App\Services\LaporanService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class LaporanParameterBuilder
{
    private LaporanService $laporanService;

    public function __construct(LaporanService $laporanService)
    {
        $this->laporanService = $laporanService;
    }

    /**
     * Build parameter form definition for frontend
     *
     * @param string $storedProcedureName
     * @return array
     */
    public function buildParameterForm(string $storedProcedureName): array
    {
        $parameters = $this->laporanService->analyzeStoredProcedure($storedProcedureName);

        if (empty($parameters)) {
            return [
                'parameters' => [],
                'form_config' => [
                    'title' => 'Parameter Form',
                    'layout' => 'vertical',
                    'validation' => true
                ]
            ];
        }

        $formParameters = [];

        foreach ($parameters as $param) {
            $formParam = [
                'name' => $param['name'],
                'label' => $this->generateLabel($param['name']),
                'widget' => $param['ui_type']['widget'],
                'type' => $param['ui_type']['type'],
                'required' => $param['validation_rules']['required'] ?? false,
                'default_value' => $param['default_value'],
                'validation_rules' => $param['validation_rules']
            ];

            // Add specific configurations based on widget type
            switch ($param['ui_type']['widget']) {
                case 'select':
                    if ($param['ui_type']['type'] === 'month') {
                        $formParam['options'] = $this->generateMonthOptions();
                    }
                    break;

                case 'year-picker':
                    $formParam['options'] = $this->generateYearOptions();
                    break;

                case 'autocomplete':
                    if ($param['lookup_source']) {
                        $formParam['data_source'] = $this->getLookupData($param['lookup_source']);
                    }
                    break;

                case 'number':
                    if (isset($param['validation_rules']['max_length'])) {
                        $formParam['max_length'] = $param['validation_rules']['max_length'];
                    }
                    break;

                case 'input':
                    if (isset($param['validation_rules']['max_length'])) {
                        $formParam['max_length'] = $param['validation_rules']['max_length'];
                    }
                    break;
            }

            $formParameters[] = $formParam;
        }

        return [
            'parameters' => $formParameters,
            'form_config' => [
                'title' => 'Parameter Input',
                'layout' => 'vertical',
                'validation' => true,
                'submit_text' => 'Generate Report',
                'reset_text' => 'Reset Form'
            ]
        ];
    }

    /**
     * Generate month options for dropdown
     *
     * @return array
     */
    public function generateMonthOptions(): array
    {
        return [
            ['value' => 1, 'label' => 'Januari'],
            ['value' => 2, 'label' => 'Februari'],
            ['value' => 3, 'label' => 'Maret'],
            ['value' => 4, 'label' => 'April'],
            ['value' => 5, 'label' => 'Mei'],
            ['value' => 6, 'label' => 'Juni'],
            ['value' => 7, 'label' => 'Juli'],
            ['value' => 8, 'label' => 'Agustus'],
            ['value' => 9, 'label' => 'September'],
            ['value' => 10, 'label' => 'Oktober'],
            ['value' => 11, 'label' => 'November'],
            ['value' => 12, 'label' => 'Desember']
        ];
    }

    /**
     * Generate year options for dropdown
     *
     * @param int $yearsBack
     * @param int $yearsForward
     * @return array
     */
    public function generateYearOptions(int $yearsBack = 5, int $yearsForward = 2): array
    {
        $currentYear = (int)date('Y');
        $options = [];

        for ($year = $currentYear - $yearsBack; $year <= $currentYear + $yearsForward; $year++) {
            $options[] = ['value' => $year, 'label' => (string)$year];
        }

        return $options;
    }

    /**
     * Get lookup data for autocomplete fields
     *
     * @param string $tableName
     * @param int $limit
     * @return array
     */
    public function getLookupData(string $tableName, int $limit = 100): array
    {
        try {
            $query = match ($tableName) {
                'DBBARANG' => "SELECT TOP {$limit} KODEBRG as value, NAMABRG as label FROM DBBARANG WHERE NAMABRG IS NOT NULL ORDER BY NAMABRG",
                'DBSUPPLIER' => "SELECT TOP {$limit} KODESUP as value, NAMASUP as label FROM DBSUPPLIER WHERE NAMASUP IS NOT NULL ORDER BY NAMASUP",
                'DBCUSTOMER' => "SELECT TOP {$limit} KODECUS as value, NAMACUS as label FROM DBCUSTOMER WHERE NAMACUS IS NOT NULL ORDER BY NAMACUS",
                'DBGROUP' => "SELECT TOP {$limit} KODEGRP as value, NAMAGRP as label FROM DBGROUP WHERE NAMAGRP IS NOT NULL ORDER BY NAMAGRP",
                'DBDIVISI' => "SELECT TOP {$limit} KODEDIV as value, NAMADIV as label FROM DBDIVISI WHERE NAMADIV IS NOT NULL ORDER BY NAMADIV",
                default => null
            };

            if (!$query) {
                return [];
            }

            return DB::select($query);
        } catch (\Exception $e) {
            Log::error("Failed to get lookup data for {$tableName}: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Validate parameters against their definitions
     *
     * @param array $parameterDefinitions
     * @param array $inputData
     * @return array
     */
    public function validateParameters(array $parameterDefinitions, array $inputData): array
    {
        $errors = [];

        foreach ($parameterDefinitions as $param) {
            $name = $param['name'];
            $value = $inputData[$name] ?? null;
            $rules = $param['validation_rules'];

            // Required validation
            if (($rules['required'] ?? false) && (is_null($value) || $value === '')) {
                $errors[$name][] = "Field {$name} is required";
                continue;
            }

            // Skip further validation if field is empty and not required
            if (is_null($value) || $value === '') {
                continue;
            }

            // Type validation
            if (isset($rules['type'])) {
                switch ($rules['type']) {
                    case 'integer':
                        if (!is_numeric($value) || (int)$value != $value) {
                            $errors[$name][] = "Field {$name} must be an integer";
                        }
                        break;
                    case 'numeric':
                        if (!is_numeric($value)) {
                            $errors[$name][] = "Field {$name} must be numeric";
                        }
                        break;
                }
            }

            // Max length validation
            if (isset($rules['max_length']) && strlen((string)$value) > $rules['max_length']) {
                $errors[$name][] = "Field {$name} cannot exceed {$rules['max_length']} characters";
            }

            // Month validation
            if (($param['ui_type']['type'] ?? '') === 'month') {
                $monthValue = (int)$value;
                if ($monthValue < 1 || $monthValue > 12) {
                    $errors[$name][] = "Field {$name} must be between 1 and 12";
                }
            }

            // Year validation
            if (($param['ui_type']['type'] ?? '') === 'year') {
                $yearValue = (int)$value;
                $currentYear = (int)date('Y');
                if ($yearValue < 1900 || $yearValue > $currentYear + 10) {
                    $errors[$name][] = "Field {$name} must be a valid year";
                }
            }
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }

    /**
     * Format parameters for stored procedure execution
     *
     * @param array $parameterDefinitions
     * @param array $inputData
     * @return array
     */
    public function formatParametersForExecution(array $parameterDefinitions, array $inputData): array
    {
        $formattedParams = [];

        foreach ($parameterDefinitions as $param) {
            $name = $param['name'];
            $value = $inputData[$name] ?? null;
            $sqlType = strtolower($param['sql_type']);

            if (is_null($value) || $value === '') {
                $formattedParams[$name] = null;
                continue;
            }

            // Format based on SQL type
            if (str_contains($sqlType, 'int')) {
                $formattedParams[$name] = (int)$value;
            } elseif (str_contains($sqlType, 'numeric') || str_contains($sqlType, 'decimal') || str_contains($sqlType, 'float')) {
                $formattedParams[$name] = (float)$value;
            } elseif (str_contains($sqlType, 'bit')) {
                $formattedParams[$name] = (bool)$value;
            } else {
                // String types (varchar, char, text, etc.)
                $formattedParams[$name] = (string)$value;
            }
        }

        return $formattedParams;
    }

    /**
     * Generate human-readable label from parameter name
     *
     * @param string $paramName
     * @return string
     */
    private function generateLabel(string $paramName): string
    {
        return match (strtolower($paramName)) {
            'bulan' => 'Bulan',
            'tahun' => 'Tahun',
            'tanggal' => 'Tanggal',
            'tglawal' => 'Tanggal Awal',
            'tglakhir' => 'Tanggal Akhir',
            'kodebrg', 'kodebarang' => 'Kode Barang',
            'kodesup', 'kodesupplier' => 'Kode Supplier',
            'kodecus', 'kodecustomer' => 'Kode Customer',
            'kodegrp', 'kodegroup' => 'Kode Group',
            'devisi', 'divisi' => 'Divisi',
            'namabrg', 'namabarang' => 'Nama Barang',
            'userid' => 'User ID',
            default => ucfirst($paramName)
        };
    }
}