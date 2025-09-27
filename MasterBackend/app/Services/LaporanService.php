<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Collection;

class LaporanService
{
    /**
     * Get user available reports based on permissions
     *
     * @param string $userId
     * @return array
     */
    public function getUserAvailableReports(string $userId): array
    {
        $query = "
            SELECT a.KODEMENU, a.Keterangan, a.L0,
                   b.Access, b.IsDesign, b.Isexport
            FROM DBMENUREPORT a
            LEFT JOIN DBFLMENUREPORT b ON b.L1 = a.KODEMENU
            WHERE b.UserID = ? AND b.Access = 1
            ORDER BY a.L0, a.Keterangan
        ";

        return DB::select($query, [$userId]);
    }

    /**
     * Analyze stored procedure parameters with caching
     *
     * @param string $spName
     * @return array
     */
    public function analyzeStoredProcedure(string $spName): array
    {
        return Cache::remember("sp_params_{$spName}", 3600, function () use ($spName) {
            $procedure = DB::selectOne("
                SELECT m.definition
                FROM sys.sql_modules m
                JOIN sys.procedures p ON m.object_id = p.object_id
                WHERE p.name = ?
            ", [$spName]);

            if (!$procedure) {
                return [];
            }

            return $this->parseParameterDefinition($procedure->definition);
        });
    }

    /**
     * Execute stored procedure with parameters
     *
     * @param string $spName
     * @param array $parameters
     * @return array
     */
    public function executeStoredProcedure(string $spName, array $parameters): array
    {
        // Build parameter bindings dynamically
        $paramBindings = [];
        $paramList = [];

        foreach ($parameters as $name => $value) {
            $paramList[] = "@{$name} = ?";
            $paramBindings[] = $value;
        }

        $sql = "EXEC {$spName} " . implode(', ', $paramList);

        return DB::select($sql, $paramBindings);
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
        $result = DB::selectOne("
            SELECT Access
            FROM DBFLMENUREPORT
            WHERE UserID = ? AND L1 = ? AND Access = 1
        ", [$userId, $reportCode]);

        return $result !== null && $result->Access;
    }

    /**
     * Parse stored procedure parameter definition
     *
     * @param string $definition
     * @return array
     */
    private function parseParameterDefinition(string $definition): array
    {
        // Regex to extract parameters with default values
        preg_match_all('/(@\w+)\s+(\w+(?:\([^)]+\))?)\s*(?:=\s*([^,\s\r\n]+))?/i', $definition, $matches);

        $parameters = [];
        for ($i = 0; $i < count($matches[0]); $i++) {
            $paramName = $matches[1][$i];
            $paramType = $matches[2][$i];
            $defaultValue = isset($matches[3][$i]) ? trim($matches[3][$i], "'\"") : null;

            $parameters[] = [
                'name' => ltrim($paramName, '@'),
                'sql_type' => $paramType,
                'default_value' => $defaultValue,
                'ui_type' => $this->detectParameterType($paramType, $paramName),
                'validation_rules' => $this->generateValidationRules($paramType),
                'lookup_source' => $this->detectLookupSource($paramName)
            ];
        }

        return $parameters;
    }

    /**
     * Detect UI parameter type based on SQL type and name
     *
     * @param string $sqlType
     * @param string $paramName
     * @return array
     */
    private function detectParameterType(string $sqlType, string $paramName): array
    {
        $paramNameLower = strtolower($paramName);
        $sqlTypeLower = strtolower($sqlType);

        return match (true) {
            str_contains($paramNameLower, 'bulan') => ['type' => 'month', 'widget' => 'select'],
            str_contains($paramNameLower, 'tahun') => ['type' => 'year', 'widget' => 'year-picker'],
            str_contains($paramNameLower, 'tanggal') => ['type' => 'date', 'widget' => 'date-picker'],
            str_contains($paramNameLower, 'kode') => ['type' => 'lookup', 'widget' => 'autocomplete'],
            preg_match('/varchar\((\d+)\)/', $sqlTypeLower) => ['type' => 'string', 'widget' => 'input'],
            preg_match('/numeric\((\d+),(\d+)\)/', $sqlTypeLower) => ['type' => 'decimal', 'widget' => 'number'],
            str_contains($sqlTypeLower, 'int') => ['type' => 'integer', 'widget' => 'number'],
            default => ['type' => 'string', 'widget' => 'input']
        };
    }

    /**
     * Generate validation rules based on SQL type
     *
     * @param string $sqlType
     * @return array
     */
    private function generateValidationRules(string $sqlType): array
    {
        $rules = ['required' => false];

        if (preg_match('/varchar\((\d+)\)/', strtolower($sqlType), $matches)) {
            $rules['max_length'] = (int)$matches[1];
        }

        if (str_contains(strtolower($sqlType), 'int')) {
            $rules['type'] = 'integer';
        }

        if (preg_match('/numeric\((\d+),(\d+)\)/', strtolower($sqlType), $matches)) {
            $rules['type'] = 'numeric';
            $rules['precision'] = (int)$matches[1];
            $rules['scale'] = (int)$matches[2];
        }

        return $rules;
    }

    /**
     * Detect lookup source table based on parameter name
     *
     * @param string $paramName
     * @return string|null
     */
    private function detectLookupSource(string $paramName): ?string
    {
        $paramNameLower = strtolower($paramName);

        return match (true) {
            str_contains($paramNameLower, 'kodebrg') || str_contains($paramNameLower, 'kodebarang') => 'DBBARANG',
            str_contains($paramNameLower, 'kodesup') || str_contains($paramNameLower, 'kodesupplier') => 'DBSUPPLIER',
            str_contains($paramNameLower, 'kodecus') || str_contains($paramNameLower, 'kodecustomer') => 'DBCUSTOMER',
            str_contains($paramNameLower, 'kodegrp') || str_contains($paramNameLower, 'kodegroup') => 'DBGROUP',
            str_contains($paramNameLower, 'devisi') || str_contains($paramNameLower, 'divisi') => 'DBDIVISI',
            default => null
        };
    }
}