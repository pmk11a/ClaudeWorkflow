<?php

namespace App\Services;

use Exception;

class FilterComponentFactory
{
    /**
     * Create filter component configuration for frontend
     *
     * @param array $filterConfig
     * @return array
     */
    public function createFilterComponent(array $filterConfig): array
    {
        $filterType = $filterConfig['filterType'];

        switch ($filterType) {
            case 'date':
                return $this->createDateFilter($filterConfig);

            case 'daterange':
                return $this->createDateRangeFilter($filterConfig);

            case 'select':
                return $this->createSelectFilter($filterConfig);

            case 'text':
                return $this->createTextFilter($filterConfig);

            case 'lookup':
                return $this->createLookupFilter($filterConfig);

            case 'checkbox':
                return $this->createCheckboxFilter($filterConfig);

            case 'radio':
                return $this->createRadioFilter($filterConfig);

            case 'number':
                return $this->createNumberFilter($filterConfig);

            default:
                throw new Exception("Unsupported filter type: {$filterType}");
        }
    }

    /**
     * Create multiple filter components for a report
     *
     * @param array $filtersConfig
     * @return array
     */
    public function createFilterComponents(array $filtersConfig): array
    {
        $components = [];

        foreach ($filtersConfig as $filterConfig) {
            try {
                $component = $this->createFilterComponent($filterConfig);
                $components[] = $component;
            } catch (Exception $e) {
                // Log error but continue with other filters
                \Log::warning('FilterComponentFactory - Failed to create filter component', [
                    'filterConfig' => $filterConfig,
                    'error' => $e->getMessage()
                ]);
            }
        }

        return $components;
    }

    /**
     * Create date filter component
     *
     * @param array $filterConfig
     * @return array
     */
    private function createDateFilter(array $filterConfig): array
    {
        return [
            'type' => 'date',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => $filterConfig['isRequired'],
            'defaultValue' => $filterConfig['defaultValue'] ?? null,
            'props' => [
                'placeholder' => 'Pilih tanggal',
                'format' => $filterConfig['filterConfig']['dateFormat'] ?? 'DD/MM/YYYY',
                'showTime' => $filterConfig['filterConfig']['showTime'] ?? false,
                'allowClear' => !$filterConfig['isRequired']
            ],
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Create date range filter component
     *
     * @param array $filterConfig
     * @return array
     */
    private function createDateRangeFilter(array $filterConfig): array
    {
        return [
            'type' => 'daterange',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => $filterConfig['isRequired'],
            'defaultValue' => $this->parseDateRangeDefault($filterConfig['defaultValue'] ?? null),
            'props' => [
                'placeholder' => ['Tanggal Awal', 'Tanggal Akhir'],
                'format' => $filterConfig['filterConfig']['dateFormat'] ?? 'DD/MM/YYYY',
                'allowClear' => !$filterConfig['isRequired'],
                'separator' => ' s/d ',
                'ranges' => $this->getDateRangePresets($filterConfig['filterConfig'] ?? [])
            ],
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Create select dropdown filter component
     *
     * @param array $filterConfig
     * @return array
     */
    private function createSelectFilter(array $filterConfig): array
    {
        return [
            'type' => 'select',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => $filterConfig['isRequired'],
            'defaultValue' => $filterConfig['defaultValue'] ?? null,
            'props' => [
                'placeholder' => 'Pilih ' . strtolower($filterConfig['label']),
                'allowClear' => !$filterConfig['isRequired'],
                'showSearch' => $filterConfig['filterConfig']['searchable'] ?? true,
                'filterOption' => true,
                'multiple' => $filterConfig['filterConfig']['multiple'] ?? false
            ],
            'optionsSource' => $filterConfig['optionsSource'] ?? null,
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Create text input filter component
     *
     * @param array $filterConfig
     * @return array
     */
    private function createTextFilter(array $filterConfig): array
    {
        return [
            'type' => 'text',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => $filterConfig['isRequired'],
            'defaultValue' => $filterConfig['defaultValue'] ?? null,
            'props' => [
                'placeholder' => 'Masukkan ' . strtolower($filterConfig['label']),
                'allowClear' => true,
                'maxLength' => $filterConfig['filterConfig']['maxLength'] ?? null,
                'prefix' => $filterConfig['filterConfig']['prefix'] ?? null,
                'suffix' => $filterConfig['filterConfig']['suffix'] ?? null,
                'exactMatch' => $filterConfig['filterConfig']['exactMatch'] ?? false
            ],
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Create lookup filter component (text with browse button)
     *
     * @param array $filterConfig
     * @return array
     */
    private function createLookupFilter(array $filterConfig): array
    {
        return [
            'type' => 'lookup',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => $filterConfig['isRequired'],
            'defaultValue' => $filterConfig['defaultValue'] ?? null,
            'props' => [
                'placeholder' => 'Masukkan atau pilih ' . strtolower($filterConfig['label']),
                'allowClear' => true,
                'showButton' => true,
                'buttonText' => 'Browse',
                'exactMatch' => $filterConfig['filterConfig']['exactMatch'] ?? false,
                'displayField' => $filterConfig['filterConfig']['displayField'] ?? 'name',
                'valueField' => $filterConfig['filterConfig']['valueField'] ?? 'code'
            ],
            'optionsSource' => $filterConfig['optionsSource'] ?? null,
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Create checkbox filter component
     *
     * @param array $filterConfig
     * @return array
     */
    private function createCheckboxFilter(array $filterConfig): array
    {
        return [
            'type' => 'checkbox',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => false, // Checkboxes are rarely required
            'defaultValue' => $this->parseCheckboxDefault($filterConfig['defaultValue'] ?? false),
            'props' => [
                'checkedChildren' => $filterConfig['filterConfig']['checkedText'] ?? 'Ya',
                'unCheckedChildren' => $filterConfig['filterConfig']['uncheckedText'] ?? 'Tidak',
                'size' => $filterConfig['filterConfig']['size'] ?? 'default'
            ],
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Create radio group filter component
     *
     * @param array $filterConfig
     * @return array
     */
    private function createRadioFilter(array $filterConfig): array
    {
        return [
            'type' => 'radio',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => $filterConfig['isRequired'],
            'defaultValue' => $filterConfig['defaultValue'] ?? null,
            'props' => [
                'buttonStyle' => $filterConfig['filterConfig']['buttonStyle'] ?? 'outline',
                'size' => $filterConfig['filterConfig']['size'] ?? 'default',
                'optionType' => $filterConfig['filterConfig']['optionType'] ?? 'default' // default | button
            ],
            'optionsSource' => $filterConfig['optionsSource'] ?? null,
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Create number input filter component
     *
     * @param array $filterConfig
     * @return array
     */
    private function createNumberFilter(array $filterConfig): array
    {
        return [
            'type' => 'number',
            'name' => $filterConfig['filterName'],
            'label' => $filterConfig['label'],
            'required' => $filterConfig['isRequired'],
            'defaultValue' => $filterConfig['defaultValue'] ?? null,
            'props' => [
                'placeholder' => 'Masukkan ' . strtolower($filterConfig['label']),
                'min' => $filterConfig['filterConfig']['min'] ?? null,
                'max' => $filterConfig['filterConfig']['max'] ?? null,
                'step' => $filterConfig['filterConfig']['step'] ?? 1,
                'precision' => $filterConfig['filterConfig']['precision'] ?? 0,
                'formatter' => $filterConfig['filterConfig']['formatter'] ?? null,
                'parser' => $filterConfig['filterConfig']['parser'] ?? null,
                'showOperator' => $filterConfig['filterConfig']['showOperator'] ?? false,
                'operators' => ['=', '>', '<', '>=', '<=', '!=']
            ],
            'validation' => $this->buildValidationRules($filterConfig),
            'fieldName' => $filterConfig['fieldName']
        ];
    }

    /**
     * Build validation rules from filter configuration
     *
     * @param array $filterConfig
     * @return array
     */
    private function buildValidationRules(array $filterConfig): array
    {
        $rules = [];

        if ($filterConfig['isRequired']) {
            $rules[] = ['required' => true, 'message' => $filterConfig['label'] . ' harus diisi'];
        }

        if (isset($filterConfig['validationRules']) && is_array($filterConfig['validationRules'])) {
            $rules = array_merge($rules, $filterConfig['validationRules']);
        }

        return $rules;
    }

    /**
     * Parse date range default value
     *
     * @param mixed $defaultValue
     * @return array|null
     */
    private function parseDateRangeDefault($defaultValue): ?array
    {
        if (!$defaultValue) {
            return null;
        }

        if (is_string($defaultValue)) {
            // Handle special cases like "current_month", "current_year"
            switch ($defaultValue) {
                case 'current_month':
                    return [
                        'start' => date('Y-m-01'),
                        'end' => date('Y-m-t')
                    ];
                case 'current_year':
                    return [
                        'start' => date('Y-01-01'),
                        'end' => date('Y-12-31')
                    ];
                case 'last_month':
                    return [
                        'start' => date('Y-m-01', strtotime('last month')),
                        'end' => date('Y-m-t', strtotime('last month'))
                    ];
                default:
                    return json_decode($defaultValue, true);
            }
        }

        return is_array($defaultValue) ? $defaultValue : null;
    }

    /**
     * Parse checkbox default value
     *
     * @param mixed $defaultValue
     * @return bool
     */
    private function parseCheckboxDefault($defaultValue): bool
    {
        if (is_string($defaultValue)) {
            return in_array(strtolower($defaultValue), ['true', '1', 'yes', 'on']);
        }

        return (bool) $defaultValue;
    }

    /**
     * Get date range presets
     *
     * @param array $filterConfig
     * @return array
     */
    private function getDateRangePresets(array $filterConfig): array
    {
        $presets = [
            'Hari Ini' => [date('Y-m-d'), date('Y-m-d')],
            'Kemarin' => [date('Y-m-d', strtotime('-1 day')), date('Y-m-d', strtotime('-1 day'))],
            'Minggu Ini' => [date('Y-m-d', strtotime('monday this week')), date('Y-m-d', strtotime('sunday this week'))],
            'Bulan Ini' => [date('Y-m-01'), date('Y-m-t')],
            'Bulan Lalu' => [date('Y-m-01', strtotime('last month')), date('Y-m-t', strtotime('last month'))],
            'Tahun Ini' => [date('Y-01-01'), date('Y-12-31')]
        ];

        // Allow custom presets from configuration
        if (isset($filterConfig['dateRangePresets']) && is_array($filterConfig['dateRangePresets'])) {
            $presets = array_merge($presets, $filterConfig['dateRangePresets']);
        }

        return $presets;
    }

    /**
     * Get supported filter types
     *
     * @return array
     */
    public static function getSupportedFilterTypes(): array
    {
        return [
            'date' => 'Date Picker',
            'daterange' => 'Date Range Picker',
            'select' => 'Select Dropdown',
            'text' => 'Text Input',
            'lookup' => 'Lookup with Browse',
            'checkbox' => 'Checkbox Toggle',
            'radio' => 'Radio Group',
            'number' => 'Number Input'
        ];
    }

    /**
     * Validate filter configuration
     *
     * @param array $filterConfig
     * @return array
     */
    public function validateFilterConfig(array $filterConfig): array
    {
        $errors = [];
        $requiredFields = ['filterName', 'filterType', 'fieldName', 'label'];

        foreach ($requiredFields as $field) {
            if (!isset($filterConfig[$field]) || empty($filterConfig[$field])) {
                $errors[] = "Field '{$field}' is required";
            }
        }

        $supportedTypes = array_keys(self::getSupportedFilterTypes());
        if (isset($filterConfig['filterType']) && !in_array($filterConfig['filterType'], $supportedTypes)) {
            $errors[] = "Filter type '{$filterConfig['filterType']}' is not supported";
        }

        return $errors;
    }
}