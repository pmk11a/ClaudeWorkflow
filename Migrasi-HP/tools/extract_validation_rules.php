<?php

/**
 * Delphi Validation Rules Extractor
 *
 * Scans Delphi .pas files and extracts all validation checks
 * to ensure they're migrated to Laravel
 *
 * Usage: php extract_validation_rules.php <module_name>
 * Example: php extract_validation_rules.php FrmPPL
 */

class DelphiValidationExtractor
{
    private $delphiPath = 'd:\\ykka\\migrasi\\pwt';
    private $laravelPath = 'd:\\ykka\\migrasi\\app';
    private $validations = [];
    private $patterns = [
        'SELECT_QUERY' => "/SQL\\.Add\\s*\\(\\s*['\"]\\s*SELECT\\s+([^'\"]+from\\s+(\\w+))/i",
        'RECORDCOUNT_CHECK' => '/RecordCount\s*[><=]+\s*(\d+)/i',
        'ISEMPTY_CHECK' => '/\.IsEmpty\s*=\s*(true|false)/i',
        'ISLOCK_PERIODE' => '/IsLockPeriode\s*\(/i',
        'CHECK_FORM' => '/CheckForm\w+/i',
        'MESSAGE_DLG' => '/MessageDlg\s*\(\s*[\'"]([^"\']+)/i',
        'DB_QUERY_PATTERN' => '/with\s+DM\.\w+\s+do|DM\.\w+\.(SQL|Open|ExecSQL)/i',
    ];

    public function __construct()
    {
        echo "=== Delphi Validation Rules Extractor ===\n\n";
    }

    /**
     * Extract all validation rules from a Delphi procedure
     */
    public function extractFromProcedure($fileName, $procedureName, $procedureCode)
    {
        $validations = [];

        // Check for SQL SELECT queries (case-insensitive)
        if (preg_match_all("/SQL\s*\.\s*Add\s*\(\s*['\"]SELECT\s+([^'\"]*from\s+(\w+))/i", $procedureCode, $matches)) {
            foreach ($matches[2] as $idx => $table) {
                $query = $matches[1][$idx] ?? '';
                $validations[] = [
                    'type' => 'DATABASE_CHECK',
                    'table' => strtoupper(trim($table)),
                    'query' => substr(trim($query), 0, 80),
                    'procedure' => $procedureName,
                    'file' => $fileName,
                    'detail' => 'Validates data before operation',
                ];
            }
        }

        // Check for RecordCount validation (verification after SELECT)
        if (preg_match_all('/RecordCount\s*[><=]+\s*(\d+)/', $procedureCode, $matches)) {
            if (!empty($matches[0])) {
                $validations[] = [
                    'type' => 'RECORD_COUNT_VALIDATION',
                    'procedure' => $procedureName,
                    'file' => $fileName,
                    'detail' => 'Check if table has records before operation',
                ];
            }
        }

        // Check for IsEmpty validation
        if (preg_match_all('/\.IsEmpty\s*=\s*(true|false)/i', $procedureCode, $matches)) {
            if (!empty($matches[0])) {
                $validations[] = [
                    'type' => 'EMPTY_CHECK_VALIDATION',
                    'procedure' => $procedureName,
                    'file' => $fileName,
                    'detail' => 'Check if dataset is empty before operation',
                ];
            }
        }

        // Check for period lock
        if (preg_match('/IsLockPeriode\s*\(/', $procedureCode)) {
            $validations[] = [
                'type' => 'PERIOD_LOCK_CHECK',
                'procedure' => $procedureName,
                'file' => $fileName,
                'detail' => 'Must check DBLOCKPERIODE before create/update/delete',
            ];
        }

        // Check for CheckFormMaster or similar form validations
        if (preg_match_all('/CheckForm(\w+)/', $procedureCode, $matches)) {
            foreach ($matches[1] as $checkName) {
                $validations[] = [
                    'type' => 'FORM_VALIDATION',
                    'check' => 'CheckForm' . $checkName,
                    'procedure' => $procedureName,
                    'file' => $fileName,
                    'detail' => 'Validate form data before operation',
                ];
            }
        }

        // Extract error/message messages
        if (preg_match_all("/MessageDlg\s*\(\s*['\"]([^'\"]{10,})/i", $procedureCode, $matches)) {
            foreach ($matches[1] as $message) {
                // Skip generic messages
                if (strlen(trim($message)) > 10) {
                    $validations[] = [
                        'type' => 'ERROR_MESSAGE',
                        'message' => substr($message, 0, 100),
                        'procedure' => $procedureName,
                        'file' => $fileName,
                        'detail' => 'User-facing error message that must be replicated',
                    ];
                }
            }
        }

        // Check for general database operations
        if (preg_match_all('/(with\s+DM\.\w+\s+do|DM\.\w+\.ExecSQL|DM\.\w+\.Open)/i', $procedureCode, $matches)) {
            if (count($matches[0]) > 0 && !in_array('DATABASE_CHECK', array_column($validations, 'type'))) {
                // Only add if not already detected
                $validations[] = [
                    'type' => 'DATABASE_OPERATION',
                    'procedure' => $procedureName,
                    'file' => $fileName,
                    'detail' => 'Database operation found - verify validation before/after',
                ];
            }
        }

        return $validations;
    }

    /**
     * Scan all Delphi files for a module
     */
    public function scanModule($moduleName)
    {
        // Search recursively for .pas files with module name
        $cmd = "find \"{$this->delphiPath}\" -name \"{$moduleName}*.pas\" -type f";
        $output = shell_exec($cmd);
        $files = array_filter(explode("\n", trim($output)));

        $allValidations = [];

        foreach ($files as $file) {
            if (!file_exists($file)) {
                continue;
            }

            echo "Scanning: " . basename($file) . " ({$file})\n";
            $content = file_get_contents($file);

            // Extract all procedures
            if (preg_match_all('/procedure\s+T\w+\.(\w+)\s*\([^)]*\)\s*;/i', $content, $matches)) {
                foreach ($matches[1] as $procedureName) {
                    // Find procedure code block
                    $procStart = strpos($content, "procedure T{$procedureName}");
                    $procEnd = strpos($content, "\nend;", $procStart) + 4;
                    $procCode = substr($content, $procStart, $procEnd - $procStart);

                    $validations = $this->extractFromProcedure(basename($file), $procedureName, $procCode);
                    $allValidations = array_merge($allValidations, $validations);
                }
            }
        }

        return $allValidations;
    }

    /**
     * Check if validation exists in Laravel code
     */
    public function checkLaravelImplementation($validation)
    {
        $result = [
            'validation' => $validation,
            'implemented' => false,
            'files' => [],
            'evidence' => [],
        ];

        if ($validation['type'] === 'DATABASE_CHECK') {
            $table = $validation['table'];
            // Search Laravel files for this table check
            $searchPatterns = [
                "'{$table}'",
                '::where',
                '->exists()',
                '->count()',
                "DB::table('{$table}')",
            ];

            foreach ($searchPatterns as $pattern) {
                $cmd = "grep -r \"$pattern\" \"{$this->laravelPath}\" 2>/dev/null";
                $output = shell_exec($cmd);
                if ($output) {
                    $result['implemented'] = true;
                    $result['evidence'][] = $pattern;
                    break;
                }
            }
        }

        if ($validation['type'] === 'PERIOD_LOCK_CHECK') {
            $cmd = "grep -r \"isLockPeriode\\|LockPeriodService\" \"{$this->laravelPath}\" 2>/dev/null";
            $output = shell_exec($cmd);
            if ($output) {
                $result['implemented'] = true;
                $result['evidence'][] = 'Period lock check found in Laravel';
            }
        }

        return $result;
    }

    /**
     * Generate validation requirements report
     */
    public function generateReport($moduleName, $validations)
    {
        $report = "# Validation Requirements Report: {$moduleName}\n\n";
        $report .= "Generated: " . date('Y-m-d H:i:s') . "\n\n";

        $report .= "## Summary\n";
        $report .= "- Total Validations Found: " . count($validations) . "\n";
        $report .= "- Database Checks: " . count(array_filter($validations, fn($v) => $v['type'] === 'DATABASE_CHECK')) . "\n";
        $report .= "- Period Locks: " . count(array_filter($validations, fn($v) => $v['type'] === 'PERIOD_LOCK_CHECK')) . "\n";
        $report .= "- Form Checks: " . count(array_filter($validations, fn($v) => $v['type'] === 'FORM_VALIDATION')) . "\n\n";

        $report .= "## Detailed Validations\n\n";

        $groupedByType = [];
        foreach ($validations as $v) {
            $type = $v['type'];
            if (!isset($groupedByType[$type])) {
                $groupedByType[$type] = [];
            }
            $groupedByType[$type][] = $v;
        }

        foreach ($groupedByType as $type => $items) {
            $report .= "### {$type}\n\n";

            foreach ($items as $item) {
                $report .= "**Procedure:** {$item['procedure']}\n";
                $report .= "**File:** {$item['file']}\n";

                if (isset($item['table'])) {
                    $report .= "**Table:** {$item['table']}\n";
                }
                if (isset($item['message'])) {
                    $report .= "**Message:** {$item['message']}\n";
                }
                if (isset($item['detail'])) {
                    $report .= "**Detail:** {$item['detail']}\n";
                }

                // Check Laravel implementation
                $laravelCheck = $this->checkLaravelImplementation($item);
                $status = $laravelCheck['implemented'] ? '✅ IMPLEMENTED' : '❌ NOT FOUND';
                $report .= "**Laravel Status:** {$status}\n";

                if ($laravelCheck['evidence']) {
                    $report .= "**Evidence:** " . implode(', ', $laravelCheck['evidence']) . "\n";
                }

                $report .= "\n";
            }
        }

        return $report;
    }

    /**
     * Get line number of validation in source code
     */
    private function getLineNumber($code, $searchText)
    {
        if (!$searchText) {
            return '?';
        }
        $pos = strpos($code, $searchText);
        return substr_count($code, "\n", 0, $pos) + 1;
    }

    /**
     * Main execution
     */
    public function run($moduleName)
    {
        echo "Extracting validations from: {$moduleName}\n";
        echo "Delphi path: {$this->delphiPath}\n";
        echo "Laravel path: {$this->laravelPath}\n\n";

        $validations = $this->scanModule($moduleName);

        if (empty($validations)) {
            echo "No validations found for {$moduleName}\n";
            return;
        }

        echo "\nFound " . count($validations) . " validation rules\n\n";

        $report = $this->generateReport($moduleName, $validations);

        // Save report
        $reportFile = dirname(__DIR__) . "/.claude/migrations/{$moduleName}_VALIDATION_REQUIREMENTS.md";
        file_put_contents($reportFile, $report);

        echo "\nReport saved to: {$reportFile}\n";
        echo "\nGenerating validation checklist...\n\n";

        // Generate checklist
        $checklist = $this->generateChecklist($moduleName, $validations);
        $checklistFile = dirname(__DIR__) . "/.claude/migrations/{$moduleName}_VALIDATION_CHECKLIST.md";
        file_put_contents($checklistFile, $checklist);

        echo "Checklist saved to: {$checklistFile}\n";
    }

    /**
     * Generate migration checklist
     */
    public function generateChecklist($moduleName, $validations)
    {
        $checklist = "# {$moduleName} Migration Validation Checklist\n\n";
        $checklist .= "**This checklist ensures ALL validation rules from Delphi are implemented in Laravel**\n\n";

        $groupedByProcedure = [];
        foreach ($validations as $v) {
            $proc = $v['procedure'];
            if (!isset($groupedByProcedure[$proc])) {
                $groupedByProcedure[$proc] = [];
            }
            $groupedByProcedure[$proc][] = $v;
        }

        foreach ($groupedByProcedure as $proc => $items) {
            $checklist .= "## {$proc}\n\n";

            foreach ($items as $item) {
                $checklist .= "- [ ] **{$item['type']}**\n";

                if (isset($item['table'])) {
                    $checklist .= "  - Table: `{$item['table']}`\n";
                }
                if (isset($item['message'])) {
                    $checklist .= "  - Message: {$item['message']}\n";
                }
                if (isset($item['detail'])) {
                    $checklist .= "  - Detail: {$item['detail']}\n";
                }

                $checklist .= "  - Delphi: {$item['file']} → {$item['procedure']}\n";
                $checklist .= "  - Laravel: [ ] Find equivalent implementation\n";
                $checklist .= "\n";
            }
        }

        return $checklist;
    }
}

// Run
if (php_sapi_name() === 'cli') {
    $moduleName = $argv[1] ?? 'FrmPPL';

    $extractor = new DelphiValidationExtractor();
    $extractor->run($moduleName);
} else {
    echo "This script must be run from command line\n";
}
