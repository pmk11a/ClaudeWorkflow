<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class LaporanConfigService
{
    private const CACHE_PREFIX = 'report_config_';
    private const CACHE_TTL = 3600; // 1 hour

    /**
     * Get hybrid report configuration by report code
     *
     * @param string $reportCode
     * @return array|null
     */
    public function getReportConfig(string $reportCode): ?array
    {
        $cacheKey = self::CACHE_PREFIX . $reportCode;

        return Cache::remember($cacheKey, self::CACHE_TTL, function () use ($reportCode) {
            try {
                // Get main configuration from DBREPORTCONFIG
                $config = DB::select("
                    SELECT
                        ID, KODEREPORT, CONFIG_TYPE, STOREDPROC, CONFIG_JSON,
                        IS_ACTIVE, CREATED_AT, UPDATED_AT
                    FROM DBREPORTCONFIG
                    WHERE KODEREPORT = ? AND IS_ACTIVE = 1
                ", [$reportCode]);

                if (empty($config)) {
                    return null;
                }

                $mainConfig = (array) $config[0];

                // Get header configuration
                $header = DB::select("
                    SELECT
                        TITLE, SUBTITLE, SHOW_DATE, SHOW_PARAMS, SHOW_LOGO,
                        ORIENTATION, PAGE_SIZE
                    FROM DBREPORTHEADER
                    WHERE KODEREPORT = ? AND IS_ACTIVE = 1
                ", [$reportCode]);

                // Get column configuration
                $columns = DB::select("
                    SELECT
                        COLUMN_NAME, COLUMN_LABEL, WIDTH, ALIGNMENT, DATA_TYPE,
                        FORMAT_MASK, SORT_ORDER, IS_VISIBLE
                    FROM DBREPORTCOLUMN
                    WHERE KODEREPORT = ? AND IS_ACTIVE = 1 AND IS_VISIBLE = 1
                    ORDER BY SORT_ORDER
                ", [$reportCode]);

                // Get grouping configuration
                $groups = DB::select("
                    SELECT
                        GROUP_FIELD, GROUP_LABEL, SHOW_HEADER, SHOW_FOOTER,
                        SHOW_SUM, SUM_FIELDS, PAGE_BREAK, SORT_ORDER
                    FROM DBREPORTGROUP
                    WHERE KODEREPORT = ? AND IS_ACTIVE = 1
                    ORDER BY SORT_ORDER
                ", [$reportCode]);

                // Combine all configurations
                $fullConfig = [
                    'main' => $mainConfig,
                    'header' => !empty($header) ? (array) $header[0] : null,
                    'columns' => array_map(function ($col) {
                        return (array) $col;
                    }, $columns),
                    'groups' => array_map(function ($group) {
                        $groupArray = (array) $group;
                        // Parse SUM_FIELDS JSON if it exists
                        if (!empty($groupArray['SUM_FIELDS'])) {
                            $groupArray['SUM_FIELDS'] = json_decode($groupArray['SUM_FIELDS'], true) ?? [];
                        }
                        return $groupArray;
                    }, $groups)
                ];

                return $fullConfig;

            } catch (\Exception $e) {
                Log::error('Report Config Service Error', [
                    'report_code' => $reportCode,
                    'error' => $e->getMessage()
                ]);
                return null;
            }
        });
    }

    /**
     * Get all available report configurations for user
     *
     * @param string $userId
     * @return array
     */
    public function getUserAvailableReports(string $userId): array
    {
        try {
            // Get reports based on user menu permissions
            $reports = DB::select("
                SELECT DISTINCT
                    c.KODEREPORT,
                    c.CONFIG_TYPE,
                    c.STOREDPROC,
                    h.TITLE,
                    h.SUBTITLE,
                    CASE
                        WHEN f.ISCETAK = 1 THEN 1
                        ELSE 0
                    END as CAN_PRINT,
                    CASE
                        WHEN f.ISEXPORT = 1 THEN 1
                        ELSE 0
                    END as CAN_EXPORT
                FROM DBREPORTCONFIG c
                LEFT JOIN DBREPORTHEADER h ON c.KODEREPORT = h.KODEREPORT AND h.IS_ACTIVE = 1
                INNER JOIN DBFLMENU f ON f.L1 = '9001' -- Report menu
                WHERE c.IS_ACTIVE = 1
                  AND f.USERID = ?
                  AND f.HASACCESS = 1
                ORDER BY h.TITLE, c.KODEREPORT
            ", [$userId]);

            return array_map(function ($report) {
                return (array) $report;
            }, $reports);

        } catch (\Exception $e) {
            Log::error('Get User Available Reports Error', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }

    /**
     * Validate user access to specific report
     *
     * @param string $userId
     * @param string $reportCode
     * @return bool
     */
    public function validateReportAccess(string $userId, string $reportCode): bool
    {
        try {
            $access = DB::select("
                SELECT COUNT(*) as has_access
                FROM DBREPORTCONFIG c
                INNER JOIN DBFLMENU f ON f.L1 = '9001'
                WHERE c.KODEREPORT = ?
                  AND c.IS_ACTIVE = 1
                  AND f.USERID = ?
                  AND f.HASACCESS = 1
            ", [$reportCode, $userId]);

            return !empty($access) && $access[0]->has_access > 0;

        } catch (\Exception $e) {
            Log::error('Validate Report Access Error', [
                'user_id' => $userId,
                'report_code' => $reportCode,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    /**
     * Get stored procedure name for report
     *
     * @param string $reportCode
     * @return string|null
     */
    public function getStoredProcedureName(string $reportCode): ?string
    {
        $config = $this->getReportConfig($reportCode);
        return $config['main']['STOREDPROC'] ?? null;
    }

    /**
     * Get report title and subtitle
     *
     * @param string $reportCode
     * @return array
     */
    public function getReportMetadata(string $reportCode): array
    {
        $config = $this->getReportConfig($reportCode);

        if (!$config || !$config['header']) {
            return [
                'title' => 'Report ' . $reportCode,
                'subtitle' => null
            ];
        }

        return [
            'title' => $config['header']['TITLE'] ?? 'Report ' . $reportCode,
            'subtitle' => $config['header']['SUBTITLE'] ?? null
        ];
    }

    /**
     * Get formatted column definitions for display
     *
     * @param string $reportCode
     * @return array
     */
    public function getColumnDefinitions(string $reportCode): array
    {
        $config = $this->getReportConfig($reportCode);

        if (!$config || empty($config['columns'])) {
            return [];
        }

        return array_map(function ($column) {
            return [
                'name' => $column['COLUMN_NAME'],
                'label' => $column['COLUMN_LABEL'],
                'width' => (int) $column['WIDTH'],
                'alignment' => strtolower($column['ALIGNMENT']),
                'data_type' => strtolower($column['DATA_TYPE']),
                'format_mask' => $column['FORMAT_MASK'],
                'visible' => (bool) $column['IS_VISIBLE']
            ];
        }, $config['columns']);
    }

    /**
     * Get grouping definitions for report
     *
     * @param string $reportCode
     * @return array
     */
    public function getGroupingDefinitions(string $reportCode): array
    {
        $config = $this->getReportConfig($reportCode);

        if (!$config || empty($config['groups'])) {
            return [];
        }

        return array_map(function ($group) {
            return [
                'field' => $group['GROUP_FIELD'],
                'label' => $group['GROUP_LABEL'],
                'show_header' => (bool) $group['SHOW_HEADER'],
                'show_footer' => (bool) $group['SHOW_FOOTER'],
                'show_sum' => (bool) $group['SHOW_SUM'],
                'sum_fields' => $group['SUM_FIELDS'] ?? [],
                'page_break' => (bool) $group['PAGE_BREAK']
            ];
        }, $config['groups']);
    }

    /**
     * Clear cache for specific report
     *
     * @param string $reportCode
     * @return void
     */
    public function clearCache(string $reportCode): void
    {
        $cacheKey = self::CACHE_PREFIX . $reportCode;
        Cache::forget($cacheKey);
    }

    /**
     * Clear all report configuration cache
     *
     * @return void
     */
    public function clearAllCache(): void
    {
        // This is a simple implementation - in production you might want
        // to use cache tags for more efficient clearing
        $reports = DB::select("SELECT DISTINCT KODEREPORT FROM DBREPORTCONFIG WHERE IS_ACTIVE = 1");

        foreach ($reports as $report) {
            $this->clearCache($report->KODEREPORT);
        }
    }

    /**
     * Save report configuration (for future admin interface)
     *
     * @param string $reportCode
     * @param array $configData
     * @return bool
     */
    public function saveReportConfig(string $reportCode, array $configData): bool
    {
        try {
            DB::beginTransaction();

            // Update or insert main config
            if (isset($configData['main'])) {
                DB::statement("
                    IF EXISTS (SELECT 1 FROM DBREPORTCONFIG WHERE KODEREPORT = ?)
                        UPDATE DBREPORTCONFIG SET
                            CONFIG_TYPE = ?, STOREDPROC = ?, CONFIG_JSON = ?,
                            UPDATED_AT = GETDATE()
                        WHERE KODEREPORT = ?
                    ELSE
                        INSERT INTO DBREPORTCONFIG (KODEREPORT, CONFIG_TYPE, STOREDPROC, CONFIG_JSON)
                        VALUES (?, ?, ?, ?)
                ", [
                    $reportCode,
                    $configData['main']['config_type'],
                    $configData['main']['stored_proc'],
                    json_encode($configData['main']['config_json'] ?? []),
                    $reportCode,
                    $reportCode,
                    $configData['main']['config_type'],
                    $configData['main']['stored_proc'],
                    json_encode($configData['main']['config_json'] ?? [])
                ]);
            }

            // Update header configuration
            if (isset($configData['header'])) {
                DB::statement("
                    IF EXISTS (SELECT 1 FROM DBREPORTHEADER WHERE KODEREPORT = ?)
                        UPDATE DBREPORTHEADER SET
                            TITLE = ?, SUBTITLE = ?, SHOW_DATE = ?, SHOW_PARAMS = ?,
                            SHOW_LOGO = ?, ORIENTATION = ?, PAGE_SIZE = ?,
                            UPDATED_AT = GETDATE()
                        WHERE KODEREPORT = ?
                    ELSE
                        INSERT INTO DBREPORTHEADER (KODEREPORT, TITLE, SUBTITLE, SHOW_DATE, SHOW_PARAMS, SHOW_LOGO, ORIENTATION, PAGE_SIZE)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ", [
                    $reportCode,
                    $configData['header']['TITLE'] ?? '',
                    $configData['header']['SUBTITLE'] ?? '',
                    $configData['header']['SHOW_DATE'] ? 1 : 0,
                    $configData['header']['SHOW_PARAMS'] ? 1 : 0,
                    $configData['header']['SHOW_LOGO'] ? 1 : 0,
                    $configData['header']['ORIENTATION'] ?? 'PORTRAIT',
                    $configData['header']['PAGE_SIZE'] ?? 'A4',
                    $reportCode,
                    $reportCode,
                    $configData['header']['TITLE'] ?? '',
                    $configData['header']['SUBTITLE'] ?? '',
                    $configData['header']['SHOW_DATE'] ? 1 : 0,
                    $configData['header']['SHOW_PARAMS'] ? 1 : 0,
                    $configData['header']['SHOW_LOGO'] ? 1 : 0,
                    $configData['header']['ORIENTATION'] ?? 'PORTRAIT',
                    $configData['header']['PAGE_SIZE'] ?? 'A4'
                ]);
            }

            // Update columns configuration
            if (isset($configData['columns']) && is_array($configData['columns'])) {
                // Delete existing columns for this report
                DB::delete("DELETE FROM DBREPORTCOLUMN WHERE KODEREPORT = ?", [$reportCode]);

                // Insert updated columns
                foreach ($configData['columns'] as $index => $column) {
                    DB::insert("
                        INSERT INTO DBREPORTCOLUMN (KODEREPORT, COLUMN_NAME, COLUMN_LABEL, WIDTH, ALIGNMENT, DATA_TYPE, FORMAT_MASK, SORT_ORDER, IS_VISIBLE)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ", [
                        $reportCode,
                        $column['COLUMN_NAME'] ?? $column['name'] ?? '',
                        $column['COLUMN_LABEL'] ?? $column['label'] ?? '',
                        $column['WIDTH'] ?? 100,
                        $column['ALIGNMENT'] ?? 'LEFT',
                        $column['DATA_TYPE'] ?? 'TEXT',
                        $column['FORMAT_MASK'] ?? '',
                        $column['SORT_ORDER'] ?? $index + 1,
                        isset($column['IS_VISIBLE']) ? ($column['IS_VISIBLE'] ? 1 : 0) : 1
                    ]);
                }
            }

            // Update groups configuration
            if (isset($configData['groups']) && is_array($configData['groups'])) {
                // Delete existing groups for this report
                DB::delete("DELETE FROM DBREPORTGROUP WHERE KODEREPORT = ?", [$reportCode]);

                // Insert updated groups
                foreach ($configData['groups'] as $index => $group) {
                    DB::insert("
                        INSERT INTO DBREPORTGROUP (KODEREPORT, GROUP_FIELD, GROUP_LABEL, SHOW_HEADER, SHOW_FOOTER, SHOW_SUM, SUM_FIELDS, PAGE_BREAK, SORT_ORDER)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ", [
                        $reportCode,
                        $group['GROUP_FIELD'] ?? '',
                        $group['GROUP_LABEL'] ?? '',
                        isset($group['SHOW_HEADER']) ? ($group['SHOW_HEADER'] ? 1 : 0) : 1,
                        isset($group['SHOW_FOOTER']) ? ($group['SHOW_FOOTER'] ? 1 : 0) : 1,
                        isset($group['SHOW_SUM']) ? ($group['SHOW_SUM'] ? 1 : 0) : 0,
                        json_encode($group['SUM_FIELDS'] ?? []),
                        isset($group['PAGE_BREAK']) ? ($group['PAGE_BREAK'] ? 1 : 0) : 0,
                        $group['SORT_ORDER'] ?? $index + 1
                    ]);
                }
            }

            DB::commit();
            $this->clearCache($reportCode);

            return true;

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Save Report Config Error', [
                'report_code' => $reportCode,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }
}