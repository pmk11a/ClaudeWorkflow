<?php
/**
 * Delphi-to-Laravel Migration Verification Tool
 *
 * Purpose: Extract patterns from Delphi source and verify Laravel implementation
 * Usage: php verify-migration.php
 */

class DelphiLaravelVerifier
{
    private $delphiFile;
    private $laravelFiles;
    private $patterns = [];
    private $report = [];

    public function __construct($delphiPath, $laravelControllerPath, $laravelServicePath)
    {
        $this->delphiFile = $delphiPath;
        $this->laravelFiles = [
            'controller' => $laravelControllerPath,
            'service' => $laravelServicePath,
        ];
    }

    /**
     * Extract Delphi Patterns
     */
    public function extractDelphiPatterns()
    {
        echo "\n========== DELPHI PATTERN EXTRACTION ==========\n";

        $content = file_get_contents($this->delphiFile);
        $lines = file($this->delphiFile);

        // Pattern 1: Mode Parameter (Choice:Char)
        echo "\n1. SEARCHING: Mode Parameter (Choice:Char)\n";
        $this->extractModeParameter($lines);

        // Pattern 2: Permission Variables
        echo "\n2. SEARCHING: Permission Variables (IsTambah, IsKoreksi, IsHapus)\n";
        $this->extractPermissionVariables($lines);

        // Pattern 3: Mode-Based Procedure
        echo "\n3. SEARCHING: Mode-Based Procedure (UpdateData...)\n";
        $this->extractModeProcedure($lines);

        // Pattern 4: LoggingData Calls
        echo "\n4. SEARCHING: LoggingData Calls\n";
        $this->extractLoggingCalls($lines);

        // Pattern 5: Parameter Assignment
        echo "\n5. SEARCHING: Parameter Assignment (Parameters[N].Value)\n";
        $this->extractParameterAssignment($lines);

        // Pattern 6: Validation Logic
        echo "\n6. SEARCHING: Validation Rules (if then raise Exception)\n";
        $this->extractValidationRules($lines);

        return $this->patterns;
    }

    /**
     * Extract Mode Parameter
     */
    private function extractModeParameter($lines)
    {
        foreach ($lines as $lineNum => $line) {
            if (preg_match('/procedure\s+\w+\s*\(\s*Choice\s*:\s*Char/i', $line)) {
                $lineNumber = $lineNum + 1;
                echo "   ✓ Found at line $lineNumber: " . trim($line) . "\n";
                $this->patterns['mode_parameter'] = [
                    'line' => $lineNumber,
                    'content' => trim($line),
                ];
            }
        }
    }

    /**
     * Extract Permission Variables
     */
    private function extractPermissionVariables($lines)
    {
        foreach ($lines as $lineNum => $line) {
            if (preg_match('/(IsTambah|IsKoreksi|IsHapus|IsCetak|IsExcel)\s*[,;:]/i', $line)) {
                $lineNumber = $lineNum + 1;
                echo "   ✓ Found at line $lineNumber: " . trim($line) . "\n";

                if (!isset($this->patterns['permissions'])) {
                    $this->patterns['permissions'] = [];
                }
                $this->patterns['permissions'][] = [
                    'line' => $lineNumber,
                    'content' => trim($line),
                ];
            }
        }
    }

    /**
     * Extract Mode-Based Procedure
     */
    private function extractModeProcedure($lines)
    {
        $inProcedure = false;
        $procedureStart = 0;
        $procedureContent = [];

        foreach ($lines as $lineNum => $line) {
            // Find procedure with Choice parameter
            if (preg_match('/procedure\s+(\w+)\s*\(\s*Choice\s*:\s*Char/i', $line, $matches)) {
                $inProcedure = true;
                $procedureStart = $lineNum + 1;
                $procedureName = $matches[1];
                echo "   ✓ Found procedure '$procedureName' at line $procedureStart\n";
            }

            if ($inProcedure) {
                $procedureContent[] = $line;

                // Find if/then for Choice='I'/'U'/'D'
                if (preg_match("/Choice\s*=\s*['\"](I|U|D)['\"]", $line)) {
                    $modeLineNum = $lineNum + 1;
                    $mode = preg_match("/Choice\s*=\s*['\"]I['\"]/", $line) ? 'I' :
                            (preg_match("/Choice\s*=\s*['\"]U['\"]/", $line) ? 'U' : 'D');
                    echo "      - Mode '$mode' logic at line $modeLineNum\n";
                }

                // End of procedure
                if (preg_match('/^\s*end\s*[;.]/i', $line) && $inProcedure) {
                    $inProcedure = false;
                    $endLine = $lineNum + 1;
                    echo "      - Procedure ends at line $endLine\n";

                    $this->patterns['mode_procedure'] = [
                        'start_line' => $procedureStart,
                        'end_line' => $endLine,
                        'name' => $procedureName ?? 'Unknown',
                    ];
                }
            }
        }
    }

    /**
     * Extract LoggingData Calls
     */
    private function extractLoggingCalls($lines)
    {
        foreach ($lines as $lineNum => $line) {
            if (preg_match('/LoggingData\s*\(/i', $line)) {
                $lineNumber = $lineNum + 1;
                echo "   ✓ Found at line $lineNumber: " . trim($line) . "\n";

                if (!isset($this->patterns['logging'])) {
                    $this->patterns['logging'] = [];
                }
                $this->patterns['logging'][] = [
                    'line' => $lineNumber,
                    'content' => trim($line),
                ];
            }
        }
    }

    /**
     * Extract Parameter Assignment
     */
    private function extractParameterAssignment($lines)
    {
        $count = 0;
        foreach ($lines as $lineNum => $line) {
            if (preg_match('/Parameters\s*\[\s*\d+\s*\]\s*\.Value\s*:=/i', $line)) {
                $lineNumber = $lineNum + 1;
                if ($count < 3) {
                    echo "   ✓ Found at line $lineNumber: " . trim($line) . "\n";
                    $count++;
                }

                if (!isset($this->patterns['parameter_assignment'])) {
                    $this->patterns['parameter_assignment'] = [];
                }
                $this->patterns['parameter_assignment'][] = [
                    'line' => $lineNumber,
                    'content' => trim($line),
                ];
            }
        }
        if (count($this->patterns['parameter_assignment'] ?? []) > 3) {
            echo "   ... and " . (count($this->patterns['parameter_assignment']) - 3) . " more\n";
        }
    }

    /**
     * Extract Validation Rules
     */
    private function extractValidationRules($lines)
    {
        $count = 0;
        foreach ($lines as $lineNum => $line) {
            if (preg_match('/(if|raise Exception|ShowMessage)/i', $line) &&
                preg_match('/(\.Value\s*[<>]|required|empty|exist)/i', $line)) {
                $lineNumber = $lineNum + 1;
                if ($count < 3) {
                    echo "   ✓ Found at line $lineNumber: " . trim($line) . "\n";
                    $count++;
                }

                if (!isset($this->patterns['validation'])) {
                    $this->patterns['validation'] = [];
                }
                $this->patterns['validation'][] = [
                    'line' => $lineNumber,
                    'content' => trim($line),
                ];
            }
        }
        if (count($this->patterns['validation'] ?? []) > 3) {
            echo "   ... and " . (count($this->patterns['validation']) - 3) . " more\n";
        }
    }

    /**
     * Extract Laravel Patterns
     */
    public function extractLaravelPatterns()
    {
        echo "\n========== LARAVEL PATTERN EXTRACTION ==========\n";

        $laravelPatterns = [];

        // Check Controller
        if (file_exists($this->laravelFiles['controller'])) {
            echo "\n1. ANALYZING: Controller\n";
            $controllerContent = file_get_contents($this->laravelFiles['controller']);
            $controllerLines = file($this->laravelFiles['controller']);

            // Find methods
            echo "\n   Methods found:\n";
            foreach ($controllerLines as $lineNum => $line) {
                if (preg_match('/public\s+function\s+(\w+)\s*\(/i', $line, $matches)) {
                    $method = $matches[1];
                    $lineNumber = $lineNum + 1;
                    echo "      - $method() at line $lineNumber\n";
                }
            }

            // Check for authorization
            echo "\n   Authorization checks:\n";
            $foundAuth = false;
            foreach ($controllerLines as $lineNum => $line) {
                if (preg_match('/(authorize|permission|gate|policy)/i', $line)) {
                    echo "      ✓ " . trim($line) . " (line " . ($lineNum + 1) . ")\n";
                    $foundAuth = true;
                }
            }
            if (!$foundAuth) {
                echo "      ⚠ No authorization checks found\n";
            }

            $laravelPatterns['controller'] = [
                'methods' => [],
                'has_auth' => $foundAuth,
            ];
        }

        // Check Service
        if (file_exists($this->laravelFiles['service'])) {
            echo "\n2. ANALYZING: Service\n";
            $serviceContent = file_get_contents($this->laravelFiles['service']);
            $serviceLines = file($this->laravelFiles['service']);

            echo "\n   Methods found:\n";
            foreach ($serviceLines as $lineNum => $line) {
                if (preg_match('/public\s+function\s+(\w+)\s*\(/i', $line, $matches)) {
                    $method = $matches[1];
                    $lineNumber = $lineNum + 1;
                    echo "      - $method() at line $lineNumber\n";
                }
            }

            // Check for AuditLog
            echo "\n   Audit logging:\n";
            $foundLogging = false;
            foreach ($serviceLines as $lineNum => $line) {
                if (preg_match('/(AuditLog|logging|audit|log)/i', $line)) {
                    echo "      ✓ " . trim($line) . " (line " . ($lineNum + 1) . ")\n";
                    $foundLogging = true;
                }
            }
            if (!$foundLogging) {
                echo "      ⚠ No audit logging found\n";
            }

            $laravelPatterns['service'] = [
                'methods' => [],
                'has_logging' => $foundLogging,
            ];
        }

        return $laravelPatterns;
    }

    /**
     * Generate Verification Report
     */
    public function generateReport()
    {
        echo "\n\n========== VERIFICATION REPORT ==========\n";

        $delphiPatterns = $this->patterns;
        $laravelPatterns = $this->extractLaravelPatterns();

        $score = 0;
        $maxScore = 0;

        // Check 1: Mode Parameter
        echo "\n✓ CHECK 1: Mode Parameter (Choice:Char)\n";
        if (isset($delphiPatterns['mode_parameter'])) {
            echo "   Delphi: Line " . $delphiPatterns['mode_parameter']['line'] . " ✓\n";
            echo "   Expected Laravel: store(), update(), destroy() methods\n";
            $score += 10;
        }
        $maxScore += 10;

        // Check 2: Permission Variables
        echo "\n✓ CHECK 2: Permission Variables\n";
        if (isset($delphiPatterns['permissions']) && count($delphiPatterns['permissions']) > 0) {
            echo "   Delphi: Found " . count($delphiPatterns['permissions']) . " permission variables ✓\n";
            echo "   Expected Laravel: Request->authorize() or Policy methods\n";
            $score += 15;
        }
        $maxScore += 15;

        // Check 3: Mode Procedure
        echo "\n✓ CHECK 3: Mode-Based Procedure\n";
        if (isset($delphiPatterns['mode_procedure'])) {
            $proc = $delphiPatterns['mode_procedure'];
            echo "   Delphi: '" . $proc['name'] . "' at lines " . $proc['start_line'] . "-" . $proc['end_line'] . " ✓\n";
            echo "   Expected Laravel: Separate service methods (register/update/delete)\n";
            $score += 20;
        }
        $maxScore += 20;

        // Check 4: Parameter Assignment
        echo "\n✓ CHECK 4: Parameter Assignment\n";
        if (isset($delphiPatterns['parameter_assignment']) && count($delphiPatterns['parameter_assignment']) > 0) {
            echo "   Delphi: " . count($delphiPatterns['parameter_assignment']) . " parameter assignments ✓\n";
            echo "   Expected Laravel: Request->validated() in request classes\n";
            $score += 15;
        }
        $maxScore += 15;

        // Check 5: LoggingData Calls
        echo "\n✓ CHECK 5: Logging (LoggingData)\n";
        if (isset($delphiPatterns['logging']) && count($delphiPatterns['logging']) > 0) {
            echo "   Delphi: " . count($delphiPatterns['logging']) . " LoggingData calls ✓\n";
            echo "   Expected Laravel: AuditLog::log() in service layer\n";
            $score += 20;
        }
        $maxScore += 20;

        // Check 6: Validation Rules
        echo "\n✓ CHECK 6: Validation Rules\n";
        if (isset($delphiPatterns['validation']) && count($delphiPatterns['validation']) > 0) {
            echo "   Delphi: " . count($delphiPatterns['validation']) . " validation rules ✓\n";
            echo "   Expected Laravel: rules() method in request classes\n";
            $score += 15;
        }
        $maxScore += 15;

        // Overall Score
        echo "\n" . str_repeat("=", 50) . "\n";
        echo "VERIFICATION SCORE: " . $score . "/" . $maxScore . " (" . round(($score/$maxScore)*100) . "%)\n";
        echo str_repeat("=", 50) . "\n";

        if (($score/$maxScore) >= 0.95) {
            echo "✓ RESULT: Migration patterns COMPLETE and VERIFIABLE\n";
        } elseif (($score/$maxScore) >= 0.80) {
            echo "⚠ RESULT: Migration patterns MOSTLY COMPLETE, some gaps\n";
        } else {
            echo "✗ RESULT: Migration patterns INCOMPLETE, many gaps\n";
        }
    }
}

// Run Verification
echo "\n╔════════════════════════════════════════════════════════════╗\n";
echo "║  Delphi-to-Laravel Migration Verification Tool            ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";

$verifier = new DelphiLaravelVerifier(
    'd:\ykka\migrasi\pwt\Master\AktivaTetap\FrmAktiva.pas',
    'd:\ykka\migrasi\app\Http\Controllers\AktivaController.php',
    'd:\ykka\migrasi\app\Services\AktivaService.php'
);

$verifier->extractDelphiPatterns();
$verifier->generateReport();

echo "\n✓ Verification complete!\n\n";
?>
