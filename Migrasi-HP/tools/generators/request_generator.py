#!/usr/bin/env python3
"""
Laravel Request Generator
Generates FormRequest classes for Store/Update operations

Features:
- Separate StoreRequest and UpdateRequest classes
- Authorization based on detected permissions
- Validation rules from Delphi validation patterns
- Custom validation messages in Indonesian
- withValidator() for complex cross-field validation
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass

@dataclass
class FieldValidation:
    """Represents validation for a single field"""
    name: str
    rules: List[str]
    messages: Dict[str, str]
    is_required_for_insert: bool = True
    is_required_for_update: bool = False
    is_immutable: bool = False  # Cannot be changed in update


class LaravelRequestGenerator:
    """Generate Laravel FormRequest classes"""
    
    def __init__(self, model_name: str, module_name: str):
        self.model_name = model_name
        self.module_name = module_name.lower()
        self.fields: List[FieldValidation] = []
        self.permissions: Dict[str, str] = {}
        self.custom_validations: List[Dict[str, Any]] = []
        self.cross_field_validations: List[Dict[str, Any]] = []
        
    def add_field(self, name: str, rules: List[str], 
                  messages: Optional[Dict[str, str]] = None,
                  required_insert: bool = True,
                  required_update: bool = False,
                  immutable: bool = False):
        """Add a field with validation rules"""
        self.fields.append(FieldValidation(
            name=name,
            rules=rules,
            messages=messages or {},
            is_required_for_insert=required_insert,
            is_required_for_update=required_update,
            is_immutable=immutable
        ))
    
    def set_permissions(self, create: str = None, update: str = None, delete: str = None):
        """Set permission names for authorization"""
        if create:
            self.permissions['create'] = create
        if update:
            self.permissions['update'] = update
        if delete:
            self.permissions['delete'] = delete
    
    def add_cross_field_validation(self, condition_field: str, condition_value: Any,
                                   target_field: str, validation: str, message: str):
        """Add cross-field validation rule"""
        self.cross_field_validations.append({
            'condition_field': condition_field,
            'condition_value': condition_value,
            'target_field': target_field,
            'validation': validation,
            'message': message
        })
    
    def generate_store_request(self) -> str:
        """Generate StoreModelRequest class"""
        class_name = f"Store{self.model_name}Request"
        
        # Build rules array
        rules_lines = []
        for field in self.fields:
            field_rules = field.rules.copy()
            
            # Add required for insert if needed
            if field.is_required_for_insert and 'required' not in field_rules:
                field_rules.insert(0, 'required')
            elif not field.is_required_for_insert and 'nullable' not in field_rules:
                field_rules.insert(0, 'nullable')
            
            rules_str = '|'.join(field_rules)
            rules_lines.append(f"            '{field.name}' => '{rules_str}',")
        
        rules_block = '\n'.join(rules_lines)
        
        # Build messages array
        messages_lines = []
        for field in self.fields:
            for rule_key, message in field.messages.items():
                messages_lines.append(f"            '{field.name}.{rule_key}' => '{message}',")
        
        messages_block = '\n'.join(messages_lines) if messages_lines else "            // Custom messages here"
        
        # Build withValidator if there are cross-field validations
        with_validator = self._generate_with_validator()
        
        # Authorization
        auth_permission = self.permissions.get('create', f'create-{self.module_name}')
        
        return f'''<?php

namespace App\\Http\\Requests\\{self.model_name};

use Illuminate\\Foundation\\Http\\FormRequest;
use Illuminate\\Validation\\Rule;

/**
 * Store{self.model_name}Request
 * 
 * Form request for creating new {self.model_name} records (INSERT mode)
 * Delphi equivalent: Choice='I' in UpdateData procedure
 * 
 * @see \\App\\Services\\{self.model_name}Service::register()
 */
class {class_name} extends FormRequest
{{
    /**
     * Determine if the user is authorized to make this request.
     * 
     * Delphi equivalent: IsTambah permission check
     */
    public function authorize(): bool
    {{
        return auth()->user()->hasPermission('{auth_permission}');
    }}

    /**
     * Get the validation rules that apply to the request.
     * 
     * All fields required for INSERT mode
     */
    public function rules(): array
    {{
        return [
{rules_block}
        ];
    }}

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {{
        return [
{messages_block}
        ];
    }}

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {{
        return [
{self._generate_attributes()}
        ];
    }}
{with_validator}
}}
'''
    
    def generate_update_request(self) -> str:
        """Generate UpdateModelRequest class"""
        class_name = f"Update{self.model_name}Request"
        
        # Build rules array (different from store - some fields optional)
        rules_lines = []
        immutable_fields = []
        
        for field in self.fields:
            field_rules = field.rules.copy()
            
            # Handle immutable fields
            if field.is_immutable:
                immutable_fields.append(field.name)
                # For immutable fields, use Rule::unique with ignore
                rules_lines.append(f"            '{field.name}' => [")
                rules_lines.append(f"                'required',")
                if 'unique' in '|'.join(field_rules):
                    rules_lines.append(f"                Rule::unique('{self.module_name}s', '{field.name}')->ignore($this->route('{self.module_name}')),")
                rules_lines.append(f"            ],")
                continue
            
            # Make fields nullable for update unless specifically required
            if field.is_required_for_update:
                if 'required' not in field_rules:
                    field_rules.insert(0, 'required')
            else:
                # Remove required, add nullable
                field_rules = [r for r in field_rules if r != 'required']
                if 'nullable' not in field_rules:
                    field_rules.insert(0, 'nullable')
            
            # Remove unique constraint (handled separately)
            field_rules = [r for r in field_rules if not r.startswith('unique:')]
            
            rules_str = '|'.join(field_rules)
            rules_lines.append(f"            '{field.name}' => '{rules_str}',")
        
        rules_block = '\n'.join(rules_lines)
        
        # Build messages array
        messages_lines = []
        for field in self.fields:
            for rule_key, message in field.messages.items():
                messages_lines.append(f"            '{field.name}.{rule_key}' => '{message}',")
        
        messages_block = '\n'.join(messages_lines) if messages_lines else "            // Custom messages here"
        
        # Build prepareForValidation for immutable fields
        prepare_validation = ""
        if immutable_fields:
            prepare_validation = self._generate_prepare_for_validation(immutable_fields)
        
        # Authorization
        auth_permission = self.permissions.get('update', f'update-{self.module_name}')
        
        return f'''<?php

namespace App\\Http\\Requests\\{self.model_name};

use Illuminate\\Foundation\\Http\\FormRequest;
use Illuminate\\Validation\\Rule;

/**
 * Update{self.model_name}Request
 * 
 * Form request for updating {self.model_name} records (UPDATE mode)
 * Delphi equivalent: Choice='U' in UpdateData procedure
 * 
 * @see \\App\\Services\\{self.model_name}Service::update()
 */
class {class_name} extends FormRequest
{{
    /**
     * Determine if the user is authorized to make this request.
     * 
     * Delphi equivalent: IsKoreksi permission check
     */
    public function authorize(): bool
    {{
        return auth()->user()->hasPermission('{auth_permission}');
    }}

    /**
     * Get the validation rules that apply to the request.
     * 
     * Some fields are optional for UPDATE mode
     * Immutable fields cannot be changed
     */
    public function rules(): array
    {{
        return [
{rules_block}
        ];
    }}

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {{
        return [
{messages_block}
        ];
    }}

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {{
        return [
{self._generate_attributes()}
        ];
    }}
{prepare_validation}
}}
'''
    
    def generate_delete_request(self) -> str:
        """Generate DeleteModelRequest class (optional, for soft delete validation)"""
        class_name = f"Delete{self.model_name}Request"
        auth_permission = self.permissions.get('delete', f'delete-{self.module_name}')
        
        return f'''<?php

namespace App\\Http\\Requests\\{self.model_name};

use Illuminate\\Foundation\\Http\\FormRequest;

/**
 * Delete{self.model_name}Request
 * 
 * Form request for deleting {self.model_name} records (DELETE mode)
 * Delphi equivalent: Choice='D' in UpdateData procedure
 * 
 * @see \\App\\Services\\{self.model_name}Service::delete()
 */
class {class_name} extends FormRequest
{{
    /**
     * Determine if the user is authorized to make this request.
     * 
     * Delphi equivalent: IsHapus permission check
     */
    public function authorize(): bool
    {{
        return auth()->user()->hasPermission('{auth_permission}');
    }}

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {{
        return [
            'reason' => 'nullable|string|max:500',
        ];
    }}

    /**
     * Additional validation before delete
     */
    public function withValidator($validator)
    {{
        $validator->after(function ($validator) {{
            // Add any pre-delete checks here
            // Example: Check if record is used elsewhere
            // $model = $this->route('{self.module_name}');
            // if ($model->hasRelatedRecords()) {{
            //     $validator->errors()->add('id', 'Cannot delete: record is in use');
            // }}
        }});

        return $validator;
    }}
}}
'''
    
    def _generate_with_validator(self) -> str:
        """Generate withValidator method for cross-field validation"""
        if not self.cross_field_validations:
            return ""
        
        checks = []
        for cv in self.cross_field_validations:
            condition = f"$this->get('{cv['condition_field']}') == '{cv['condition_value']}'"
            check = f"if (!$this->get('{cv['target_field']}'))"
            message = cv['message']
            
            checks.append(f'''
            // Cross-field validation: {cv['target_field']} required when {cv['condition_field']}={cv['condition_value']}
            if ({condition}) {{
                {check} {{
                    $validator->errors()->add('{cv['target_field']}', '{message}');
                }}
            }}''')
        
        checks_str = '\n'.join(checks)
        
        return f'''

    /**
     * Configure the validator instance.
     * 
     * Cross-field validation rules from Delphi
     */
    public function withValidator($validator)
    {{
        $validator->after(function ($validator) {{{checks_str}
        }});

        return $validator;
    }}'''
    
    def _generate_prepare_for_validation(self, immutable_fields: List[str]) -> str:
        """Generate prepareForValidation for immutable fields"""
        merges = []
        for field in immutable_fields:
            merges.append(f"            '{field}' => $this->route('{self.module_name}')->{field},")
        
        merge_str = '\n'.join(merges)
        
        return f'''

    /**
     * Prepare the data for validation.
     * 
     * Preserve immutable fields from being changed
     */
    protected function prepareForValidation(): void
    {{
        $this->merge([
{merge_str}
        ]);
    }}'''
    
    def _generate_attributes(self) -> str:
        """Generate attributes array for friendly field names"""
        attrs = []
        for field in self.fields:
            # Convert snake_case to Title Case
            friendly_name = field.name.replace('_', ' ').title()
            attrs.append(f"            '{field.name}' => '{friendly_name}',")
        
        return '\n'.join(attrs) if attrs else "            // Field attributes here"
    
    def generate_all(self) -> Dict[str, str]:
        """Generate all request classes"""
        return {
            f"Store{self.model_name}Request.php": self.generate_store_request(),
            f"Update{self.model_name}Request.php": self.generate_update_request(),
            f"Delete{self.model_name}Request.php": self.generate_delete_request(),
        }


def create_from_parser_result(parser_result: Dict[str, Any], model_name: str) -> LaravelRequestGenerator:
    """Create RequestGenerator from parser result"""
    module_name = parser_result.get('unit_name', model_name).lower()
    
    # Remove common prefixes
    for prefix in ['Frm', 'frm', 'Fr', 'fr', 'Form']:
        if module_name.startswith(prefix.lower()):
            module_name = module_name[len(prefix):]
            break
    
    generator = LaravelRequestGenerator(model_name, module_name)
    
    # Set permissions from detected permission checks
    for perm in parser_result.get('permission_checks', []):
        if perm.permission_type == 'create':
            generator.permissions['create'] = perm.laravel_permission
        elif perm.permission_type == 'update':
            generator.permissions['update'] = perm.laravel_permission
        elif perm.permission_type == 'delete':
            generator.permissions['delete'] = perm.laravel_permission
    
    # Add fields from validation rules
    fields_added = set()
    for rule in parser_result.get('validation_rules', []):
        field_name = rule.field_name.lower()
        
        if field_name in fields_added or field_name == 'unknown':
            continue
        
        fields_added.add(field_name)
        
        # Determine if field is required based on rule type
        is_required = rule.rule_type == 'required' or rule.laravel_rule == 'required'
        
        # Build rules list
        rules = []
        if rule.laravel_rule and rule.laravel_rule != 'custom_validation':
            rules.append(rule.laravel_rule)
        
        # Build messages
        messages = {}
        if rule.error_message:
            # Map rule type to message key
            msg_key = {
                'required': 'required',
                'unique': 'unique',
                'exists': 'exists',
                'range': 'min' if 'min' in rule.laravel_rule else 'max',
                'format': 'date_format' if 'date' in rule.laravel_rule else rule.rule_type,
                'enum': 'in',
            }.get(rule.rule_type, rule.rule_type)
            messages[msg_key] = rule.error_message
        
        generator.add_field(
            name=field_name,
            rules=rules,
            messages=messages,
            required_insert=is_required,
            required_update=False,
            immutable=(rule.rule_type == 'unique')  # Unique fields are typically immutable
        )
    
    # Add cross-field validations
    for rule in parser_result.get('validation_rules', []):
        if rule.rule_type == 'conditional':
            # Parse the laravel_rule to extract condition
            # Format: required_if:condition_field,value
            if rule.laravel_rule.startswith('required_if:'):
                parts = rule.laravel_rule.replace('required_if:', '').split(',')
                if len(parts) >= 2:
                    generator.add_cross_field_validation(
                        condition_field=parts[0],
                        condition_value=parts[1],
                        target_field=rule.field_name.lower(),
                        validation='required',
                        message=rule.error_message or f'{rule.field_name} wajib diisi'
                    )
    
    return generator


if __name__ == "__main__":
    # Test the generator
    generator = LaravelRequestGenerator('Aktiva', 'aktiva')
    
    generator.set_permissions(
        create='create-aktiva',
        update='update-aktiva',
        delete='delete-aktiva'
    )
    
    generator.add_field('kode_aktiva', ['string', 'max:25', 'unique:aktivas,kode_aktiva'],
                        {'required': 'Kode Aktiva wajib diisi', 'unique': 'Kode Aktiva sudah ada'},
                        required_insert=True, immutable=True)
    generator.add_field('nama_aktiva', ['string', 'max:100'],
                        {'required': 'Nama Aktiva wajib diisi'},
                        required_insert=True)
    generator.add_field('perkiraan', ['string', 'exists:coas,kode'],
                        {'exists': 'Perkiraan tidak ditemukan'},
                        required_insert=True)
    generator.add_field('quantity', ['numeric', 'min:0.01'],
                        {'min': 'Quantity harus > 0'},
                        required_insert=True)
    generator.add_field('tipe_aktiva', ['integer', 'in:0,1'],
                        {'in': 'Tipe Aktiva tidak valid'})
    generator.add_field('serial_number', ['string', 'max:50'])
    
    # Cross-field validation
    generator.add_cross_field_validation(
        condition_field='tipe_aktiva',
        condition_value='0',
        target_field='serial_number',
        validation='required',
        message='Serial Number wajib diisi untuk tipe aktiva 0'
    )
    
    # Generate all
    files = generator.generate_all()
    
    for filename, content in files.items():
        print(f"\n{'='*70}")
        print(f" {filename}")
        print('='*70)
        print(content)
