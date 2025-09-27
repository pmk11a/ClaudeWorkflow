<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class AnalyzeReportConfig extends Command
{
    protected $signature = 'report:analyze-config';
    protected $description = 'Analyze report configuration tables structure';

    public function handle()
    {
        $this->info("🔍 Analyzing Report Configuration Tables");
        $this->info("========================================");

        // Analyze DBREPORTCONFIG
        $this->analyzeTable('DBREPORTCONFIG', 'Report Configuration');

        // Analyze DBREPORTHEADER
        $this->analyzeTable('DBREPORTHEADER', 'Report Headers');

        // Analyze DBREPORTCOLUMN
        $this->analyzeTable('DBREPORTCOLUMN', 'Report Columns');

        // Analyze DBREPORTGROUP
        $this->analyzeTable('DBREPORTGROUP', 'Report Groups');

        // Find Daftar Perkiraan specific config
        $this->findDaftarPerkiraanConfig();

        return 0;
    }

    private function analyzeTable($tableName, $description)
    {
        try {
            $this->info("\n🔎 {$description} ({$tableName}):");
            $this->info(str_repeat("-", 50));

            // Get table structure first
            $columns = DB::select("
                SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = ?
                ORDER BY ORDINAL_POSITION
            ", [$tableName]);

            $this->line("Table Structure:");
            foreach ($columns as $col) {
                $nullable = $col->IS_NULLABLE === 'YES' ? 'NULL' : 'NOT NULL';
                $default = $col->COLUMN_DEFAULT ? " DEFAULT: {$col->COLUMN_DEFAULT}" : '';
                $this->line("  - {$col->COLUMN_NAME} ({$col->DATA_TYPE}) {$nullable}{$default}");
            }

            // Get sample data
            $sampleData = DB::select("SELECT TOP 5 * FROM {$tableName}");

            if (!empty($sampleData)) {
                $this->line("\nSample Data:");
                foreach ($sampleData as $index => $row) {
                    $this->line("  Row " . ($index + 1) . ":");
                    foreach ((array)$row as $key => $value) {
                        $this->line("    {$key}: " . ($value ?? 'NULL'));
                    }
                    $this->line("");
                }
            } else {
                $this->warn("  No data found in {$tableName}");
            }

        } catch (\Exception $e) {
            $this->error("  Error analyzing {$tableName}: " . $e->getMessage());
        }
    }

    private function findDaftarPerkiraanConfig()
    {
        $this->info("\n🎯 Looking for 'Daftar Perkiraan' Configuration:");
        $this->info(str_repeat("-", 50));

        try {
            // Search for Daftar Perkiraan in DBREPORTCONFIG
            $configs = DB::select("
                SELECT * FROM DBREPORTCONFIG
                WHERE
                    LOWER(ReportName) LIKE '%daftar%perkiraan%' OR
                    LOWER(ReportCode) LIKE '%daftar%perkiraan%' OR
                    LOWER(Description) LIKE '%daftar%perkiraan%' OR
                    ReportCode = '0101'
            ");

            if (!empty($configs)) {
                $this->line("Found Daftar Perkiraan configurations:");
                foreach ($configs as $config) {
                    $this->line("Config found:");
                    foreach ((array)$config as $key => $value) {
                        $this->line("  {$key}: " . ($value ?? 'NULL'));
                    }
                    $this->line("");
                }
            } else {
                $this->warn("No specific 'Daftar Perkiraan' configuration found");

                // Try to find by report code pattern
                $this->line("Searching by report code patterns...");
                $patterns = DB::select("
                    SELECT TOP 10 * FROM DBREPORTCONFIG
                    WHERE ReportCode LIKE '01%' OR ReportCode = '0101'
                ");

                foreach ($patterns as $pattern) {
                    $this->line("Pattern match:");
                    foreach ((array)$pattern as $key => $value) {
                        $this->line("  {$key}: " . ($value ?? 'NULL'));
                    }
                    $this->line("");
                }
            }

        } catch (\Exception $e) {
            $this->error("Error searching for Daftar Perkiraan config: " . $e->getMessage());
        }
    }
}