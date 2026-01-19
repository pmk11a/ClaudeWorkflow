<?php
/**
 * Migration Validation Tool
 * 
 * Validates that all Delphi validation rules are migrated to Laravel.
 * Based on Codebase Singularity "Closed Loop" principle.
 * 
 * Usage: php tools/validate_migration.php <module> <form>
 * Example: php tools/validate_migration.php PPL FrmPPL
 */

if ($argc < 3) {
    echo "Usage: php validate_migration.php <module> <form>\n";
    echo "Example: php validate_migration.php PPL FrmPPL\n";
    exit(1);
}

$module = $argv[1];
$form = $argv[2];

// Configuration
$delphiPath = 'd:/ykka/migrasi/pwt';
$laravelPath = 'd:/ykka/migrasi';

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║       Migration Validation Tool                                 ║\n";
echo "╠════════════════════════════════════════════════════════════════╣\n";
echo "║  Module: $module\n";
echo "║  Form: $form\n";
echo "║  Started: " . date('Y-m-d H:i:s') . "\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// Find Delphi source file
$pasFile = findDelphiFile($delphiPath, $form . '.pas');
if (!$pasFile) {
    echo "❌ Delphi file not found: {$form}.pas\n";
    echo "Searched in: $delphiPath\n";
    exit(1);
}

echo "✅ Found Delphi file: $pasFile\n\n";

// Parse Delphi file
$delphiContent = file_get_contents($pasFile);
$validations = extractValidations($delphiContent);

echo "📋 Found " . count($validations) . " validation rules\n\n";

// Check Laravel implementation
$issues = [];
foreach ($validations as $validation) {
    $result = checkLaravelImplementation($laravelPath, $module, $validation);
    if (!$result['implemented']) {
        $issues[] = [
            'severity' => $result['severity'],
            'validation' => $validation,
            'recommendation' => $result['recommendation']
        ];
    }
}

// Generate report
generateReport($module, $form, $validations, $issues);

/**
 * Find Delphi file recursively
 */
function findDelphiFile(string $basePath, string $filename): ?string
{
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($basePath, RecursiveDirectoryIterator::SKIP_DOTS)
    );
    
    foreach ($iterator as $file) {
        if (strtolower($file->getFilename()) === strtolower($filename)) {
            return $file->getPathname();
        }
    }
    
    return null;
}

/**
 * Extract validation rules from Delphi code
 */
function extractValidations(string $content): array
{
    $validations = [];
    
    // Pattern 1: Database queries with RecordCount check
    if (preg_match_all('/SQL\.Add\([\'"]([^"\']+)[\'"]\).*?RecordCount\s*>\s*0/s', $content, $matches)) {
        foreach ($matches[1] as $sql) {
            // Extract table name
            if (preg_match('/from\s+(\w+)/i', $sql, $tableMatch)) {
                $validations[] = [
                    'type' => 'DATABASE_CHECK',
                    'table' => strtoupper($tableMatch[1]),
                    'sql' => $sql,
                    'procedure' => extractProcedureName($content, $sql)
                ];
            }
        }
    }
    
    // Pattern 2: IsLockPeriode checks
    if (preg_match_all('/IsLockPeriode\s*\(/i', $content, $matches, PREG_OFFSET_CAPTURE)) {
        foreach ($matches[0] as $match) {
            $validations[] = [
                'type' => 'PERIOD_LOCK',
                'procedure' => extractProcedureNameAtOffset($content, $match[1])
            ];
        }
    }
    
    // Pattern 3: IsEmpty checks
    if (preg_match_all('/(\w+)\.IsEmpty\s*=\s*false/i', $content, $matches)) {
        foreach ($matches[1] as $dataset) {
            $validations[] = [
                'type' => 'EMPTY_CHECK',
                'dataset' => $dataset
            ];
        }
    }
    
    // Pattern 4: MessageDlg error messages
    if (preg_match_all('/MessageDlg\s*\(\s*[\'"]([^\'"]+)[\'"]/i', $content, $matches)) {
        foreach ($matches[1] as $message) {
            $validations[] = [
                'type' => 'ERROR_MESSAGE',
                'message' => $message
            ];
        }
    }
    
    // Pattern 5: Permission checks
    if (preg_match_all('/(IsTambah|IsKoreksi|IsHapus|IsCetak)/i', $content, $matches)) {
        foreach (array_unique($matches[1]) as $permission) {
            $validations[] = [
                'type' => 'PERMISSION_CHECK',
                'permission' => $permission
            ];
        }
    }
    
    // Pattern 6: CekOtorisasi checks
    if (preg_match_all('/CekOtorisasi/i', $content, $matches, PREG_OFFSET_CAPTURE)) {
        foreach ($matches[0] as $match) {
            $validations[] = [
                'type' => 'AUTHORIZATION_CHECK',
                'procedure' => extractProcedureNameAtOffset($content, $match[1])
            ];
        }
    }
    
    return $validations;
}

/**
 * Extract procedure name containing a string
 */
function extractProcedureName(string $content, string $needle): string
{
    $pos = strpos($content, $needle);
    if ($pos === false) return 'Unknown';
    
    return extractProcedureNameAtOffset($content, $pos);
}

/**
 * Extract procedure name at offset
 */
function extractProcedureNameAtOffset(string $content, int $offset): string
{
    $before = substr($content, 0, $offset);
    if (preg_match('/procedure\s+(\w+)\s*\([^)]*\)\s*;[^;]*$/is', $before, $match)) {
        return $match[1];
    }
    if (preg_match('/function\s+(\w+)\s*\([^)]*\)[^;]*;[^;]*$/is', $before, $match)) {
        return $match[1];
    }
    return 'Unknown';
}

/**
 * Check if validation is implemented in Laravel
 */
function checkLaravelImplementation(string $laravelPath, string $module, array $validation): array
{
    $appPath = $laravelPath . '/app';
    
    switch ($validation['type']) {
        case 'DATABASE_CHECK':
            $table = $validation['table'];
            // Look for model or DB:: query for this table
            $found = searchInFiles($appPath, ["Db{$table}", "DB::table('{$table}')", "->from('{$table}')"]);
            return [
                'implemented' => $found,
                'severity' => 'HIGH',
                'recommendation' => $found 
                    ? null 
                    : "Add database check for table {$table} in {$validation['procedure']}()"
            ];
            
        case 'PERIOD_LOCK':
            $found = searchInFiles($appPath, ['LockPeriodService', 'isLockPeriode', 'getLockedMonths']);
            return [
                'implemented' => $found,
                'severity' => 'CRITICAL',
                'recommendation' => $found
                    ? null
                    : "Add LockPeriodService check in {$validation['procedure']}()"
            ];
            
        case 'PERMISSION_CHECK':
            $permission = $validation['permission'];
            $laravelPerm = match(strtolower($permission)) {
                'istambah' => 'create',
                'iskoreksi' => 'update',
                'ishapus' => 'delete',
                'iscetak' => 'print',
                default => $permission
            };
            $found = searchInFiles($appPath . '/Policies', ["can('{$laravelPerm}'", "->can('{$laravelPerm}'"]);
            return [
                'implemented' => $found,
                'severity' => 'HIGH',
                'recommendation' => $found
                    ? null
                    : "Add {$permission} permission check (map to '{$laravelPerm}')"
            ];
            
        case 'AUTHORIZATION_CHECK':
            $found = searchInFiles($appPath, ['AuthorizationService', 'canAuthorize', 'canAuthorizeLevel']);
            return [
                'implemented' => $found,
                'severity' => 'HIGH',
                'recommendation' => $found
                    ? null
                    : "Add AuthorizationService check"
            ];
            
        case 'ERROR_MESSAGE':
            $message = $validation['message'];
            $found = searchInFiles($appPath, [$message]);
            return [
                'implemented' => $found,
                'severity' => 'LOW',
                'recommendation' => $found
                    ? null
                    : "Ensure error message exists: '{$message}'"
            ];
            
        default:
            return [
                'implemented' => true,
                'severity' => 'LOW',
                'recommendation' => null
            ];
    }
}

/**
 * Search for patterns in files
 */
function searchInFiles(string $path, array $patterns): bool
{
    if (!is_dir($path)) return false;
    
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($path, RecursiveDirectoryIterator::SKIP_DOTS)
    );
    
    foreach ($iterator as $file) {
        if ($file->getExtension() !== 'php') continue;
        
        $content = file_get_contents($file->getPathname());
        foreach ($patterns as $pattern) {
            if (stripos($content, $pattern) !== false) {
                return true;
            }
        }
    }
    
    return false;
}

/**
 * Generate validation report
 */
function generateReport(string $module, string $form, array $validations, array $issues): void
{
    $reportDir = '.claude/migrations';
    if (!is_dir($reportDir)) {
        mkdir($reportDir, 0755, true);
    }
    
    $reportFile = "{$reportDir}/{$module}_VALIDATION_GAPS.md";
    
    $critical = array_filter($issues, fn($i) => $i['severity'] === 'CRITICAL');
    $high = array_filter($issues, fn($i) => $i['severity'] === 'HIGH');
    $medium = array_filter($issues, fn($i) => $i['severity'] === 'MEDIUM');
    $low = array_filter($issues, fn($i) => $i['severity'] === 'LOW');
    
    $report = "# Migration Validation Report: {$module}\n\n";
    $report .= "Generated: " . date('Y-m-d H:i:s') . "\n\n";
    $report .= "## Summary\n";
    $report .= "- Total Validations Found: " . count($validations) . "\n";
    $report .= "- Issues Found: " . count($issues) . "\n";
    $report .= "- Migration Status: " . (count($issues) === 0 ? "✅ COMPLETE" : "⚠️ GAPS DETECTED") . "\n\n";
    
    $report .= "## Issues by Severity\n\n";
    
    if (count($critical) > 0) {
        $report .= "### 🔴 CRITICAL\n\n";
        foreach ($critical as $issue) {
            $report .= "**{$issue['validation']['procedure']}** - {$issue['recommendation']}\n\n";
        }
    }
    
    if (count($high) > 0) {
        $report .= "### 🟠 HIGH\n\n";
        foreach ($high as $issue) {
            $report .= "**{$issue['validation']['type']}** - {$issue['recommendation']}\n";
            if (isset($issue['validation']['sql'])) {
                $report .= "- Delphi: `{$issue['validation']['sql']}`\n";
            }
            $report .= "\n";
        }
    }
    
    if (count($medium) > 0) {
        $report .= "### 🟡 MEDIUM\n\n";
        foreach ($medium as $issue) {
            $report .= "- {$issue['recommendation']}\n";
        }
        $report .= "\n";
    }
    
    if (count($low) > 0) {
        $report .= "### 🔵 LOW\n\n";
        foreach ($low as $issue) {
            $report .= "- {$issue['recommendation']}\n";
        }
        $report .= "\n";
    }
    
    file_put_contents($reportFile, $report);
    
    // Console output
    echo "\n";
    echo "═══════════════════════════════════════════════════════════════\n";
    echo "                    VALIDATION REPORT\n";
    echo "═══════════════════════════════════════════════════════════════\n";
    echo "Summary:\n";
    echo "  🔴 CRITICAL: " . count($critical) . "\n";
    echo "  🟠 HIGH: " . count($high) . "\n";
    echo "  🟡 MEDIUM: " . count($medium) . "\n";
    echo "  🔵 LOW: " . count($low) . "\n";
    echo "\n";
    
    if (count($issues) > 0) {
        echo "Issues Found:\n";
        echo "─────────────────────────────────────────────────────────────────\n\n";
        
        foreach ($issues as $issue) {
            $icon = match($issue['severity']) {
                'CRITICAL' => '🔴',
                'HIGH' => '🟠',
                'MEDIUM' => '🟡',
                'LOW' => '🔵',
                default => '⚪'
            };
            
            echo "{$icon} [{$issue['severity']}] {$issue['validation']['type']}\n";
            if (isset($issue['validation']['procedure'])) {
                echo "   Procedure: {$issue['validation']['procedure']}\n";
            }
            echo "   Action: {$issue['recommendation']}\n";
            if (isset($issue['validation']['sql'])) {
                echo "   Delphi SQL: {$issue['validation']['sql']}\n";
            }
            echo "\n";
        }
    } else {
        echo "✅ All validations implemented!\n";
    }
    
    echo "═══════════════════════════════════════════════════════════════\n";
    echo "Report saved to: {$reportFile}\n";
}
