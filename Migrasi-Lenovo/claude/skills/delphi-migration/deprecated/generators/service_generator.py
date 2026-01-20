#!/usr/bin/env python3
"""
Laravel Service Generator
Generates Service classes with mode-based operations (I/U/D)

Features:
- Separate methods for INSERT, UPDATE, DELETE modes
- AuditLog integration from LoggingData() calls
- Transaction handling
- Exception handling pattern
- Change tracking for updates
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class ServiceMethod:
    """Represents a service method"""
    name: str
    mode: str  # 'I', 'U', 'D', or None
    parameters: List[Dict[str, str]]
    return_type: str
    has_audit_log: bool = True
    audit_params: Dict[str, str] = None


class LaravelServiceGenerator:
    """Generate Laravel Service classes"""
    
    def __init__(self, model_name: str, module_name: str):
        self.model_name = model_name
        self.module_name = module_name.lower()
        self.table_name = f"{self.module_name}s"  # Laravel convention
        
        # Logging configuration
        self.log_source = module_name
        self.logging_calls: List[Dict[str, Any]] = []
        
        # Additional methods to generate
        self.custom_methods: List[ServiceMethod] = []
        
        # Fields for change tracking
        self.tracked_fields: List[str] = []
        
        # Business rules
        self.pre_delete_checks: List[Dict[str, str]] = []
        self.pre_update_checks: List[Dict[str, str]] = []
        
    def set_log_source(self, source: str):
        """Set the source name for audit logging"""
        self.log_source = source
    
    def add_logging_call(self, action: str, keterangan_template: str):
        """Add logging call configuration"""
        self.logging_calls.append({
            'action': action,
            'keterangan': keterangan_template
        })
    
    def add_tracked_field(self, field_name: str):
        """Add field to track for change logging"""
        self.tracked_fields.append(field_name)
    
    def add_pre_delete_check(self, relation: str, error_message: str):
        """Add check before delete (e.g., check if used in other tables)"""
        self.pre_delete_checks.append({
            'relation': relation,
            'message': error_message
        })
    
    def add_pre_update_check(self, condition: str, error_message: str):
        """Add check before update"""
        self.pre_update_checks.append({
            'condition': condition,
            'message': error_message
        })
    
    def generate(self) -> str:
        """Generate complete Service class"""
        
        # Build pre-delete checks
        pre_delete_code = self._generate_pre_delete_checks()
        
        # Build pre-update checks  
        pre_update_code = self._generate_pre_update_checks()
        
        # Build change tracking
        change_tracking = self._generate_change_tracking()
        
        return f'''<?php

namespace App\\Services;

use App\\Models\\{self.model_name};
use App\\Support\\AuditLog;
use Exception;
use Illuminate\\Support\\Facades\\DB;
use Illuminate\\Support\\Facades\\Log;

/**
 * {self.model_name}Service
 * 
 * Service layer for {self.model_name} business logic
 * Handles INSERT (I), UPDATE (U), DELETE (D) operations
 * 
 * Delphi equivalent: UpdateData{self.model_name}(Choice:Char) procedure
 * 
 * @see \\App\\Http\\Controllers\\{self.model_name}Controller
 */
class {self.model_name}Service
{{
    /**
     * Source identifier for audit logging
     * Delphi equivalent: Source parameter in LoggingData()
     */
    private const LOG_SOURCE = '{self.log_source}';

    /**
     * Register new {self.model_name} (INSERT mode)
     * 
     * Delphi equivalent: Choice='I' branch
     * 
     * @param array $data Validated data from Store{self.model_name}Request
     * @return {self.model_name}
     * @throws Exception
     */
    public function register(array $data): {self.model_name}
    {{
        try {{
            return DB::transaction(function () use ($data) {{
                // Create the record
                ${self.module_name} = {self.model_name}::create($data);

                // Log the creation
                // Delphi: LoggingData(IDUser, 'I', '{self.log_source}', '', ...)
                $this->logActivity(
                    'I',
                    '',
                    $this->formatInsertLog(${self.module_name})
                );

                Log::info('{self.model_name} created', [
                    'id' => ${self.module_name}->id,
                    'user_id' => auth()->id(),
                ]);

                return ${self.module_name};
            }});
        }} catch (Exception $e) {{
            Log::error('{self.model_name} creation failed', [
                'error' => $e->getMessage(),
                'data' => $data,
            ]);
            throw new Exception('Gagal menyimpan data: ' . $e->getMessage());
        }}
    }}

    /**
     * Update existing {self.model_name} (UPDATE mode)
     * 
     * Delphi equivalent: Choice='U' branch
     * 
     * @param string|int $id Record identifier
     * @param array $data Validated data from Update{self.model_name}Request
     * @return {self.model_name}
     * @throws Exception
     */
    public function update($id, array $data): {self.model_name}
    {{
        try {{
            return DB::transaction(function () use ($id, $data) {{
                ${self.module_name} = {self.model_name}::findOrFail($id);
                
                // Store old values for audit trail
                $oldData = ${self.module_name}->getAttributes();
{pre_update_code}
                // Update the record
                ${self.module_name}->update($data);

                // Log the update with changes
                // Delphi: LoggingData(IDUser, 'U', '{self.log_source}', NoBukti, ...)
                $changes = $this->formatChanges($oldData, $data);
                $this->logActivity(
                    'U',
                    ${self.module_name}->id,
                    $this->formatUpdateLog(${self.module_name}, $changes)
                );

                Log::info('{self.model_name} updated', [
                    'id' => ${self.module_name}->id,
                    'changes' => $changes,
                    'user_id' => auth()->id(),
                ]);

                return ${self.module_name}->fresh();
            }});
        }} catch (Exception $e) {{
            Log::error('{self.model_name} update failed', [
                'id' => $id,
                'error' => $e->getMessage(),
            ]);
            throw new Exception('Gagal mengupdate data: ' . $e->getMessage());
        }}
    }}

    /**
     * Delete {self.model_name} (DELETE mode)
     * 
     * Delphi equivalent: Choice='D' branch
     * 
     * @param string|int $id Record identifier
     * @param string|null $reason Optional deletion reason
     * @return void
     * @throws Exception
     */
    public function delete($id, ?string $reason = null): void
    {{
        try {{
            DB::transaction(function () use ($id, $reason) {{
                ${self.module_name} = {self.model_name}::findOrFail($id);
{pre_delete_code}
                // Log before delete
                // Delphi: LoggingData(IDUser, 'D', '{self.log_source}', NoBukti, ...)
                $this->logActivity(
                    'D',
                    ${self.module_name}->id,
                    $this->formatDeleteLog(${self.module_name}, $reason)
                );

                // Perform soft delete (or hard delete if configured)
                ${self.module_name}->delete();

                Log::info('{self.model_name} deleted', [
                    'id' => $id,
                    'reason' => $reason,
                    'user_id' => auth()->id(),
                ]);
            }});
        }} catch (Exception $e) {{
            Log::error('{self.model_name} deletion failed', [
                'id' => $id,
                'error' => $e->getMessage(),
            ]);
            throw new Exception('Gagal menghapus data: ' . $e->getMessage());
        }}
    }}

    /**
     * Find {self.model_name} by ID
     * 
     * @param string|int $id
     * @return {self.model_name}
     * @throws Exception
     */
    public function find($id): {self.model_name}
    {{
        return {self.model_name}::findOrFail($id);
    }}

    /**
     * Get all {self.model_name} with optional filters
     * 
     * @param array $filters
     * @param int $perPage
     * @return \\Illuminate\\Pagination\\LengthAwarePaginator
     */
    public function getAll(array $filters = [], int $perPage = 15)
    {{
        $query = {self.model_name}::query();

        // Apply filters
        if (!empty($filters['search'])) {{
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {{
                // Add searchable fields here
                $q->where('id', 'like', "%$search%");
            }});
        }}

        if (isset($filters['is_aktif'])) {{
            $query->where('is_aktif', $filters['is_aktif']);
        }}

        return $query->orderByDesc('created_at')->paginate($perPage);
    }}

    // =========================================================================
    // AUDIT LOGGING
    // =========================================================================

    /**
     * Log activity to audit trail
     * 
     * Delphi equivalent: LoggingData(IDUser, Activity, Source, NoBukti, Keterangan)
     * 
     * @param string $activity I=Insert, U=Update, D=Delete
     * @param string $noBukti Document number (optional)
     * @param string $keterangan Description
     */
    private function logActivity(string $activity, string $noBukti, string $keterangan): void
    {{
        try {{
            AuditLog::log(
                $activity,
                self::LOG_SOURCE,
                $noBukti,
                auth()->id(),
                $keterangan
            );
        }} catch (Exception $e) {{
            // Don't fail main operation if logging fails
            Log::warning('Audit logging failed', [
                'error' => $e->getMessage(),
                'activity' => $activity,
            ]);
        }}
    }}

    /**
     * Format log message for INSERT
     */
    private function formatInsertLog({self.model_name} ${self.module_name}): string
    {{
        return sprintf(
            'Created: ID=%s',
            ${self.module_name}->id
        );
    }}

    /**
     * Format log message for UPDATE
     */
    private function formatUpdateLog({self.model_name} ${self.module_name}, string $changes): string
    {{
        return sprintf(
            'Updated: ID=%s, Changes: %s',
            ${self.module_name}->id,
            $changes ?: 'No changes'
        );
    }}

    /**
     * Format log message for DELETE
     */
    private function formatDeleteLog({self.model_name} ${self.module_name}, ?string $reason): string
    {{
        return sprintf(
            'Deleted: ID=%s%s',
            ${self.module_name}->id,
            $reason ? ", Reason: $reason" : ''
        );
    }}
{change_tracking}
}}
'''
    
    def _generate_pre_delete_checks(self) -> str:
        """Generate pre-delete validation code"""
        if not self.pre_delete_checks:
            return ""
        
        checks = []
        for check in self.pre_delete_checks:
            checks.append(f'''
                // Check if record is used in {check['relation']}
                if (${self.module_name}->{check['relation']}()->exists()) {{
                    throw new Exception('{check['message']}');
                }}''')
        
        return '\n'.join(checks)
    
    def _generate_pre_update_checks(self) -> str:
        """Generate pre-update validation code"""
        if not self.pre_update_checks:
            return ""
        
        checks = []
        for check in self.pre_update_checks:
            checks.append(f'''
                // Business rule check
                if ({check['condition']}) {{
                    throw new Exception('{check['message']}');
                }}''')
        
        return '\n'.join(checks)
    
    def _generate_change_tracking(self) -> str:
        """Generate change tracking method"""
        if not self.tracked_fields:
            # Default implementation
            return '''

    /**
     * Format changes between old and new data
     */
    private function formatChanges(array $old, array $new): string
    {
        $changes = [];
        
        foreach ($new as $key => $value) {
            if (isset($old[$key]) && $old[$key] != $value) {
                $oldValue = is_null($old[$key]) ? 'null' : $old[$key];
                $newValue = is_null($value) ? 'null' : $value;
                $changes[] = sprintf('%s: %s → %s', $key, $oldValue, $newValue);
            }
        }
        
        return implode(', ', $changes);
    }'''
        
        # Custom tracked fields
        field_checks = []
        for field in self.tracked_fields:
            field_checks.append(f"'{field}'")
        
        fields_str = ', '.join(field_checks)
        
        return f'''

    /**
     * Format changes between old and new data
     * 
     * Only tracks specific fields for audit log
     */
    private function formatChanges(array $old, array $new): string
    {{
        $trackedFields = [{fields_str}];
        $changes = [];
        
        foreach ($trackedFields as $field) {{
            if (isset($new[$field]) && isset($old[$field]) && $old[$field] != $new[$field]) {{
                $oldValue = is_null($old[$field]) ? 'null' : $old[$field];
                $newValue = is_null($new[$field]) ? 'null' : $new[$field];
                $changes[] = sprintf('%s: %s → %s', $field, $oldValue, $newValue);
            }}
        }}
        
        return implode(', ', $changes);
    }}'''


def create_from_parser_result(parser_result: Dict[str, Any], model_name: str) -> LaravelServiceGenerator:
    """Create ServiceGenerator from parser result"""
    module_name = parser_result.get('unit_name', model_name)
    
    # Remove common prefixes
    for prefix in ['Frm', 'frm', 'Fr', 'fr', 'Form']:
        if module_name.startswith(prefix):
            module_name = module_name[len(prefix):]
            break
    
    generator = LaravelServiceGenerator(model_name, module_name)
    
    # Extract log source from logging calls
    if parser_result.get('logging_calls'):
        first_log = parser_result['logging_calls'][0]
        generator.set_log_source(first_log.source_param)
    
    # Add tracked fields from validation rules
    for rule in parser_result.get('validation_rules', []):
        if rule.field_name and rule.field_name.lower() != 'unknown':
            generator.add_tracked_field(rule.field_name.lower())
    
    return generator


if __name__ == "__main__":
    # Test the generator
    generator = LaravelServiceGenerator('Aktiva', 'aktiva')
    generator.set_log_source('Aktiva')
    
    generator.add_tracked_field('kode_aktiva')
    generator.add_tracked_field('nama_aktiva')
    generator.add_tracked_field('perkiraan')
    generator.add_tracked_field('quantity')
    
    generator.add_pre_delete_check('transactions', 'Tidak dapat menghapus: Aktiva sudah digunakan dalam transaksi')
    generator.add_pre_update_check('$aktiva->is_locked', 'Tidak dapat mengubah: Aktiva sudah dikunci')
    
    print(generator.generate())
