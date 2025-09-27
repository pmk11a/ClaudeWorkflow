<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class GenerateModels extends Command
{
    protected $signature = 'generate:models';
    protected $description = 'Generate models from database tables';

    public function handle()
    {
        $this->info('Starting model generation from database: dbdapenka2');
        $this->info('========================================');
        
        // Get existing models
        $existingTables = $this->getExistingModels();
        $this->info('Found ' . count($existingTables) . ' existing models');
        
        // Get all tables from database
        $tables = DB::select("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME");
        
        $this->info('Total tables in database: ' . count($tables));
        $this->info('Starting generation for missing tables...');
        $this->line('');
        
        $generatedCount = 0;
        $skippedCount = 0;
        
        foreach ($tables as $table) {
            $tableName = $table->TABLE_NAME;
            
            // Skip if already exists
            if (in_array($tableName, $existingTables)) {
                $skippedCount++;
                continue;
            }
            
            $this->line("Generating model for table: {$tableName}... ", false);
            
            try {
                $primaryKey = $this->getPrimaryKey($tableName);
                $columns = $this->getColumns($tableName);
                
                if (empty($columns)) {
                    $this->error('SKIPPED (no columns found)');
                    continue;
                }
                
                $modelContent = $this->generateModel($tableName, $primaryKey, $columns);
                $modelName = $this->getModelName($tableName);
                $filePath = app_path("Models/{$modelName}.php");
                
                file_put_contents($filePath, $modelContent);
                $this->info("✓ Generated {$modelName}");
                $generatedCount++;
                
            } catch (\Exception $e) {
                $this->error('ERROR: ' . $e->getMessage());
            }
        }
        
        $this->line('');
        $this->info('========================================');
        $this->info('Generation Summary:');
        $this->info("- Existing models: {$skippedCount}");
        $this->info("- Generated models: {$generatedCount}");
        $this->info("- Total: " . ($skippedCount + $generatedCount));
        $this->info('========================================');
        
        return Command::SUCCESS;
    }
    
    private function getExistingModels()
    {
        $modelDir = app_path('Models');
        $files = glob($modelDir . '/*.php');
        $existingTables = [];
        
        foreach ($files as $file) {
            $content = file_get_contents($file);
            if (preg_match("/protected \\\$table = '([^']+)'/", $content, $matches)) {
                $existingTables[] = $matches[1];
            }
        }
        
        return $existingTables;
    }
    
    private function getModelName($tableName)
    {
        if (substr($tableName, 0, 2) === 'DB' || substr($tableName, 0, 2) === 'db') {
            return ucfirst(strtolower(substr($tableName, 0, 2))) . substr($tableName, 2);
        }
        return ucfirst(Str::camel($tableName));
    }
    
    private function getPrimaryKey($tableName)
    {
        try {
            $result = DB::select("
                SELECT c.COLUMN_NAME
                FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
                JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME 
                JOIN INFORMATION_SCHEMA.COLUMNS c ON ccu.COLUMN_NAME = c.COLUMN_NAME AND ccu.TABLE_NAME = c.TABLE_NAME
                WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND tc.TABLE_NAME = ?
                ORDER BY c.ORDINAL_POSITION
            ", [$tableName]);
            
            if (count($result) > 1) {
                return array_map(function($row) { return $row->COLUMN_NAME; }, $result);
            } elseif (count($result) == 1) {
                return $result[0]->COLUMN_NAME;
            }
        } catch (\Exception $e) {
            // Return null if no primary key found
        }
        return null;
    }
    
    private function getColumns($tableName)
    {
        try {
            $result = DB::select("
                SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_NAME = ?
                ORDER BY ORDINAL_POSITION
            ", [$tableName]);
            
            return $result;
        } catch (\Exception $e) {
            return [];
        }
    }
    
    private function generateCasts($columns)
    {
        $casts = [];
        foreach ($columns as $column) {
            $dataType = strtolower($column->DATA_TYPE);
            
            if (in_array($dataType, ['decimal', 'numeric', 'money', 'smallmoney', 'float', 'real'])) {
                $casts[] = "        '{$column->COLUMN_NAME}' => 'decimal:2',";
            } elseif (in_array($dataType, ['datetime', 'datetime2', 'smalldatetime', 'date', 'time'])) {
                $casts[] = "        '{$column->COLUMN_NAME}' => 'datetime',";
            } elseif (in_array($dataType, ['bit'])) {
                $casts[] = "        '{$column->COLUMN_NAME}' => 'boolean',";
            }
        }
        return $casts;
    }
    
    private function generateModel($tableName, $primaryKey, $columns)
    {
        $modelName = $this->getModelName($tableName);
        $fillable = array_map(function($col) { return $col->COLUMN_NAME; }, $columns);
        $casts = $this->generateCasts($columns);
        
        $content = "<?php\n\n";
        $content .= "namespace App\\Models;\n\n";
        $content .= "use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;\n";
        $content .= "use Illuminate\\Database\\Eloquent\\Model;\n\n";
        $content .= "class {$modelName} extends Model\n";
        $content .= "{\n";
        $content .= "    use HasFactory;\n\n";
        $content .= "    protected \$table = '{$tableName}';\n";
        
        if (is_array($primaryKey)) {
            $content .= "    protected \$primaryKey = ['" . implode("', '", $primaryKey) . "'];\n";
        } else {
            $content .= "    protected \$primaryKey = '{$primaryKey}';\n";
        }
        
        $content .= "    public \$incrementing = false;\n";
        $content .= "    protected \$keyType = 'string';\n";
        $content .= "    public \$timestamps = false;\n\n";
        
        $content .= "    protected \$fillable = [\n";
        $content .= "        '" . implode("', '", $fillable) . "'\n";
        $content .= "    ];\n\n";
        
        if (!empty($casts)) {
            $content .= "    protected \$casts = [\n";
            $content .= implode("\n", $casts) . "\n";
            $content .= "    ];\n\n";
        }
        
        // Add composite key support if needed
        if (is_array($primaryKey)) {
            $content .= "    // Composite primary key support\n";
            $content .= "    protected function setKeysForSaveQuery(\$query)\n";
            $content .= "    {\n";
            $content .= "        \$keys = \$this->getKeyName();\n";
            $content .= "        if(!is_array(\$keys)){\n";
            $content .= "            return parent::setKeysForSaveQuery(\$query);\n";
            $content .= "        }\n\n";
            $content .= "        foreach(\$keys as \$keyName){\n";
            $content .= "            \$query->where(\$keyName, '=', \$this->getKeyForSaveQuery(\$keyName));\n";
            $content .= "        }\n\n";
            $content .= "        return \$query;\n";
            $content .= "    }\n\n";
            $content .= "    protected function getKeyForSaveQuery(\$keyName = null)\n";
            $content .= "    {\n";
            $content .= "        if(is_null(\$keyName)){\n";
            $content .= "            \$keyName = \$this->getKeyName();\n";
            $content .= "        }\n\n";
            $content .= "        if (isset(\$this->original[\$keyName])) {\n";
            $content .= "            return \$this->original[\$keyName];\n";
            $content .= "        }\n\n";
            $content .= "        return \$this->getAttribute(\$keyName);\n";
            $content .= "    }\n\n";
        }
        
        $content .= "}\n";
        
        return $content;
    }
}
