#!/usr/bin/env python3
"""
Laravel Database Migration Generator
Version: 1.0

Generates Laravel database migrations from:
- DFM field definitions
- PAS stored procedure parameters
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime


@dataclass
class MigrationField:
    """Represents a database field"""
    name: str
    type: str = "string"  # string, text, integer, bigInteger, decimal, boolean, date, datetime, timestamp
    length: int = 0
    precision: int = 0
    scale: int = 0
    nullable: bool = True
    default: Any = None
    unsigned: bool = False
    unique: bool = False
    index: bool = False
    foreign_table: str = ""
    foreign_column: str = "id"
    comment: str = ""


class LaravelMigrationGenerator:
    """Generate Laravel database migrations"""
    
    # Delphi to Laravel type mapping
    TYPE_MAP = {
        'String': 'string',
        'WideString': 'string',
        'AnsiString': 'string',
        'ShortString': 'string',
        'Integer': 'integer',
        'Int64': 'bigInteger',
        'SmallInt': 'smallInteger',
        'Word': 'unsignedSmallInteger',
        'Byte': 'unsignedTinyInteger',
        'Boolean': 'boolean',
        'Double': 'double',
        'Single': 'float',
        'Currency': 'decimal',
        'Extended': 'decimal',
        'Real': 'float',
        'TDateTime': 'datetime',
        'TDate': 'date',
        'TTime': 'time',
        'Variant': 'text',
        'Memo': 'text',
        'Blob': 'binary',
        # ADO/DB types
        'ftString': 'string',
        'ftWideString': 'string',
        'ftInteger': 'integer',
        'ftSmallint': 'smallInteger',
        'ftWord': 'unsignedSmallInteger',
        'ftBoolean': 'boolean',
        'ftFloat': 'double',
        'ftCurrency': 'decimal',
        'ftDate': 'date',
        'ftTime': 'time',
        'ftDateTime': 'datetime',
        'ftMemo': 'text',
        'ftWideMemo': 'text',
        'ftBlob': 'binary',
        'ftAutoInc': 'bigIncrements',
    }
    
    def __init__(self, table_name: str, model_name: str = None):
        self.table_name = table_name.lower()
        self.model_name = model_name or table_name.title()
        
        self.fields: List[MigrationField] = []
        
        # Options
        self.with_timestamps = True
        self.with_soft_deletes = True
        self.with_created_by = True
        
    def add_field(self, name: str, **kwargs) -> 'LaravelMigrationGenerator':
        """Add a field to the migration"""
        field = MigrationField(name=name, **kwargs)
        self.fields.append(field)
        return self
    
    def add_field_from_delphi(self, name: str, delphi_type: str, size: int = 0) -> 'LaravelMigrationGenerator':
        """Add field from Delphi type"""
        laravel_type = self.TYPE_MAP.get(delphi_type, 'string')
        
        field = MigrationField(
            name=self._to_snake_case(name),
            type=laravel_type,
            length=size if laravel_type == 'string' else 0,
        )
        
        # Set precision for decimal types
        if laravel_type == 'decimal':
            field.precision = 15
            field.scale = 2
        
        self.fields.append(field)
        return self
    
    def _to_snake_case(self, name: str) -> str:
        """Convert to snake_case"""
        import re
        # Handle common patterns
        name = name.replace('ID', '_id').replace('Id', '_id')
        result = re.sub(r'([A-Z])', r'_\1', name).lower()
        return result.strip('_').replace('__', '_')
    
    def generate(self) -> str:
        """Generate migration file content"""
        timestamp = datetime.now().strftime('%Y_%m_%d_%H%M%S')
        class_name = f"Create{self.model_name.replace(' ', '')}Table"
        
        fields_code = self._generate_fields()
        
        return f'''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{{
    /**
     * Run the migrations.
     */
    public function up(): void
    {{
        Schema::create('{self.table_name}', function (Blueprint $table) {{
            $table->id();
            
{fields_code}
{self._generate_audit_fields()}
{self._generate_timestamps()}
{self._generate_indexes()}
        }});
    }}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {{
        Schema::dropIfExists('{self.table_name}');
    }}
}};
'''
    
    def _generate_fields(self) -> str:
        """Generate field definitions"""
        lines = []
        
        for field in self.fields:
            line = self._generate_field(field)
            if line:
                lines.append(f"            {line}")
        
        return '\n'.join(lines)
    
    def _generate_field(self, field: MigrationField) -> str:
        """Generate single field definition"""
        parts = ["$table"]
        
        # Type
        if field.type == 'string':
            if field.length > 0:
                parts.append(f"->string('{field.name}', {field.length})")
            else:
                parts.append(f"->string('{field.name}')")
        elif field.type == 'decimal':
            parts.append(f"->decimal('{field.name}', {field.precision}, {field.scale})")
        elif field.type in ['integer', 'bigInteger', 'smallInteger', 'tinyInteger']:
            if field.unsigned:
                parts.append(f"->unsigned{field.type.title()}('{field.name}')")
            else:
                parts.append(f"->{field.type}('{field.name}')")
        else:
            parts.append(f"->{field.type}('{field.name}')")
        
        # Nullable
        if field.nullable:
            parts.append("->nullable()")
        
        # Default
        if field.default is not None:
            if isinstance(field.default, bool):
                parts.append(f"->default({str(field.default).lower()})")
            elif isinstance(field.default, str):
                parts.append(f"->default('{field.default}')")
            else:
                parts.append(f"->default({field.default})")
        
        # Unique
        if field.unique:
            parts.append("->unique()")
        
        # Index
        if field.index:
            parts.append("->index()")
        
        # Comment
        if field.comment:
            parts.append(f"->comment('{field.comment}')")
        
        return ''.join(parts) + ";"
    
    def _generate_audit_fields(self) -> str:
        """Generate audit fields"""
        lines = []
        
        if self.with_created_by:
            lines.append("            $table->unsignedBigInteger('created_by')->nullable();")
            lines.append("            $table->unsignedBigInteger('updated_by')->nullable();")
        
        lines.append("            $table->boolean('is_aktif')->default(true);")
        
        return '\n'.join(lines)
    
    def _generate_timestamps(self) -> str:
        """Generate timestamp fields"""
        lines = []
        
        if self.with_timestamps:
            lines.append("            $table->timestamps();")
        
        if self.with_soft_deletes:
            lines.append("            $table->softDeletes();")
        
        return '\n'.join(lines)
    
    def _generate_indexes(self) -> str:
        """Generate index definitions"""
        lines = []
        
        # Foreign keys
        for field in self.fields:
            if field.foreign_table:
                lines.append(f"            $table->foreign('{field.name}')->references('{field.foreign_column}')->on('{field.foreign_table}');")
        
        # Audit field foreign keys
        if self.with_created_by:
            lines.append("            $table->foreign('created_by')->references('id')->on('users')->nullOnDelete();")
            lines.append("            $table->foreign('updated_by')->references('id')->on('users')->nullOnDelete();")
        
        return '\n'.join(lines) if lines else ""
    
    def generate_alter(self, add_fields: List[MigrationField] = None, 
                       drop_fields: List[str] = None,
                       modify_fields: List[MigrationField] = None) -> str:
        """Generate alter table migration"""
        timestamp = datetime.now().strftime('%Y_%m_%d_%H%M%S')
        
        add_code = ""
        if add_fields:
            add_lines = []
            for field in add_fields:
                add_lines.append(f"            {self._generate_field(field)}")
            add_code = '\n'.join(add_lines)
        
        drop_code = ""
        if drop_fields:
            drop_lines = [f"            $table->dropColumn('{f}');" for f in drop_fields]
            drop_code = '\n'.join(drop_lines)
        
        modify_code = ""
        if modify_fields:
            modify_lines = []
            for field in modify_fields:
                line = self._generate_field(field).replace(';', '->change();')
                modify_lines.append(f"            {line}")
            modify_code = '\n'.join(modify_lines)
        
        changes = []
        if add_code:
            changes.append(f"            // Add columns\n{add_code}")
        if modify_code:
            changes.append(f"            // Modify columns\n{modify_code}")
        if drop_code:
            changes.append(f"            // Drop columns\n{drop_code}")
        
        changes_str = '\n\n'.join(changes)
        
        return f'''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{{
    /**
     * Run the migrations.
     */
    public function up(): void
    {{
        Schema::table('{self.table_name}', function (Blueprint $table) {{
{changes_str}
        }});
    }}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {{
        Schema::table('{self.table_name}', function (Blueprint $table) {{
            // Reverse the changes
        }});
    }}
}};
'''


def create_from_dfm_result(dfm_result: dict, table_name: str) -> LaravelMigrationGenerator:
    """Create MigrationGenerator from DFM parser result"""
    generator = LaravelMigrationGenerator(table_name)
    
    for field in dfm_result.get('fields', []):
        field_name = field.field_name if hasattr(field, 'field_name') else field.get('field_name', '')
        data_type = field.data_type if hasattr(field, 'data_type') else field.get('data_type', 'string')
        
        if not field_name:
            continue
        
        # Map data type
        laravel_type = 'string'
        length = 0
        
        if data_type == 'numeric':
            laravel_type = 'decimal'
        elif data_type == 'date':
            laravel_type = 'date'
        elif data_type == 'boolean':
            laravel_type = 'boolean'
        elif data_type == 'text':
            laravel_type = 'text'
        else:
            laravel_type = 'string'
            max_len = field.max_length if hasattr(field, 'max_length') else field.get('max_length', 0)
            if max_len > 0:
                length = max_len
        
        generator.add_field(
            name=generator._to_snake_case(field_name),
            type=laravel_type,
            length=length,
            nullable=not (field.required if hasattr(field, 'required') else field.get('required', False)),
            precision=15 if laravel_type == 'decimal' else 0,
            scale=2 if laravel_type == 'decimal' else 0,
        )
    
    return generator


def create_from_stored_proc(proc_params: list, table_name: str) -> LaravelMigrationGenerator:
    """Create MigrationGenerator from stored procedure parameters"""
    generator = LaravelMigrationGenerator(table_name)
    
    for param in proc_params:
        param_name = param.get('name', '')
        param_type = param.get('data_type', 'String')
        param_size = param.get('size', 0)
        
        if not param_name or param_name.lower() in ['choice', 'result', 'return_value']:
            continue
        
        generator.add_field_from_delphi(param_name, param_type, param_size)
    
    return generator


if __name__ == "__main__":
    # Test
    generator = LaravelMigrationGenerator('aktiva', 'Aktiva')
    
    generator.add_field('kode', type='string', length=25, nullable=False, unique=True)
    generator.add_field('nama', type='string', length=100, nullable=False)
    generator.add_field('tipe', type='string', length=1, nullable=False)
    generator.add_field('tanggal_perolehan', type='date', nullable=True)
    generator.add_field('nilai_perolehan', type='decimal', precision=15, scale=2, nullable=True)
    generator.add_field('keterangan', type='text', nullable=True)
    generator.add_field('divisi_id', type='bigInteger', unsigned=True, foreign_table='divisi', foreign_column='id')
    
    print(generator.generate())
