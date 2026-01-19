#!/usr/bin/env python3
"""
Laravel Model Generator
Author: Migration Tool
Purpose: Generate Laravel Eloquent models from Delphi form definitions
"""

from typing import List, Dict, Any
import os

class LaravelModelGenerator:
    """Generate Laravel Eloquent models"""
    
    def __init__(self, table_name: str, fields: List[Dict[str, Any]]):
        self.table_name = table_name
        self.fields = fields
        self.model_name = self._generate_model_name()
        
    def _generate_model_name(self) -> str:
        """Generate model name from table name"""
        # Convert snake_case to PascalCase
        parts = self.table_name.split('_')
        return ''.join(word.capitalize() for word in parts)
    
    def _map_delphi_type_to_laravel(self, delphi_type: str) -> str:
        """Map Delphi data types to Laravel cast types"""
        type_mapping = {
            'String': 'string',
            'Integer': 'integer',
            'BCD': 'decimal:2',
            'Float': 'float',
            'Boolean': 'boolean',
            'DateTime': 'datetime',
            'Date': 'date',
            'Word': 'integer',
        }
        return type_mapping.get(delphi_type, 'string')
    
    def _determine_fillable_fields(self) -> List[str]:
        """Determine which fields should be fillable"""
        fillable = []
        excluded = ['id', 'created_at', 'updated_at', 'deleted_at']
        
        for field in self.fields:
            field_name = field.get('field_name', '').lower()
            if field_name and field_name not in excluded:
                fillable.append(field_name)
        
        return fillable
    
    def _generate_casts(self) -> Dict[str, str]:
        """Generate casts array for model"""
        casts = {}
        
        for field in self.fields:
            field_name = field.get('field_name', '').lower()
            data_type = field.get('data_type', 'String')
            
            if field_name:
                laravel_type = self._map_delphi_type_to_laravel(data_type)
                if laravel_type != 'string':  # Only add non-string types
                    casts[field_name] = laravel_type
        
        return casts
    
    def _generate_validation_rules(self) -> Dict[str, List[str]]:
        """Generate validation rules based on field properties"""
        rules = {}
        
        for field in self.fields:
            field_name = field.get('field_name', '').lower()
            if not field_name:
                continue
            
            field_rules = []
            
            # Required check
            if field.get('required', False):
                field_rules.append('required')
            else:
                field_rules.append('nullable')
            
            # Type validation
            data_type = field.get('data_type', 'String')
            if data_type in ['Integer', 'Word']:
                field_rules.append('integer')
            elif data_type in ['BCD', 'Float']:
                field_rules.append('numeric')
            elif data_type == 'Boolean':
                field_rules.append('boolean')
            elif data_type == 'DateTime':
                field_rules.append('date')
            else:
                field_rules.append('string')
                
                # Max length
                size = field.get('size', 0)
                if size > 0:
                    field_rules.append(f'max:{size}')
            
            rules[field_name] = field_rules
        
        return rules
    
    def generate(self) -> str:
        """Generate complete Laravel model code"""
        fillable = self._determine_fillable_fields()
        casts = self._generate_casts()
        
        # Generate model template
        model_code = f"""<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;
use Illuminate\\Database\\Eloquent\\SoftDeletes;

class {self.model_name} extends Model
{{
    use HasFactory, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = '{self.table_name.lower()}';

    /**
     * The primary key associated with the table.
     *
     * @var string
     */
    protected $primaryKey = 'id';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        {self._format_array(fillable)}
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        {self._format_dict(casts)}
    ];

    /**
     * The attributes that should be mutated to dates.
     *
     * @var array
     */
    protected $dates = [
        'created_at',
        'updated_at',
        'deleted_at',
    ];

    /**
     * Validation rules for this model
     *
     * @return array
     */
    public static function rules()
    {{
        return [
            {self._format_validation_rules(self._generate_validation_rules())}
        ];
    }}

    /**
     * Scope a query to only include active records.
     *
     * @param  \\Illuminate\\Database\\Eloquent\\Builder  $query
     * @return \\Illuminate\\Database\\Eloquent\\Builder
     */
    public function scopeActive($query)
    {{
        return $query->where('isaktif', 1);
    }}

    /**
     * Scope a query to only include inactive records.
     *
     * @param  \\Illuminate\\Database\\Eloquent\\Builder  $query
     * @return \\Illuminate\\Database\\Eloquent\\Builder
     */
    public function scopeInactive($query)
    {{
        return $query->where('isaktif', 0);
    }}
}}
"""
        return model_code
    
    def _format_array(self, items: List[str]) -> str:
        """Format array items for PHP"""
        if not items:
            return ""
        
        formatted = ",\n        ".join([f"'{item}'" for item in items])
        return formatted
    
    def _format_dict(self, items: Dict[str, str]) -> str:
        """Format dictionary items for PHP"""
        if not items:
            return ""
        
        formatted = ",\n        ".join([f"'{key}' => '{value}'" for key, value in items.items()])
        return formatted
    
    def _format_validation_rules(self, rules: Dict[str, List[str]]) -> str:
        """Format validation rules for PHP"""
        if not rules:
            return ""
        
        lines = []
        for field, field_rules in rules.items():
            rules_str = '|'.join(field_rules)
            lines.append(f"'{field}' => '{rules_str}'")
        
        return ",\n            ".join(lines)

if __name__ == "__main__":
    # Test the generator
    sample_fields = [
        {'field_name': 'KodeBrg', 'data_type': 'String', 'size': 25, 'required': True},
        {'field_name': 'NamaBrg', 'data_type': 'String', 'size': 100, 'required': True},
        {'field_name': 'Sat1', 'data_type': 'String', 'size': 5},
        {'field_name': 'Isi1', 'data_type': 'BCD'},
        {'field_name': 'IsAktif', 'data_type': 'Word'},
    ]
    
    generator = LaravelModelGenerator('barang', sample_fields)
    print(generator.generate())
