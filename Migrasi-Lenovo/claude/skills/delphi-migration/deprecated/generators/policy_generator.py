#!/usr/bin/env python3
"""
Laravel Policy Generator
Generates Policy classes from Delphi permission checks

Features:
- Maps IsTambah/IsKoreksi/IsHapus/IsCetak/IsExcel to Policy methods
- Supports role-based and permission-based authorization
- Generates both simple and complex authorization logic
"""

from typing import List, Dict, Any, Optional


class LaravelPolicyGenerator:
    """Generate Laravel Policy classes"""
    
    # Standard permission methods
    STANDARD_METHODS = {
        'viewAny': {'delphi': None, 'description': 'View list of records'},
        'view': {'delphi': None, 'description': 'View single record'},
        'create': {'delphi': 'IsTambah', 'description': 'Create new record'},
        'update': {'delphi': 'IsKoreksi', 'description': 'Update existing record'},
        'delete': {'delphi': 'IsHapus', 'description': 'Delete record'},
        'restore': {'delphi': None, 'description': 'Restore soft-deleted record'},
        'forceDelete': {'delphi': None, 'description': 'Permanently delete record'},
    }
    
    # Additional permission methods (non-CRUD)
    ADDITIONAL_METHODS = {
        'print': {'delphi': 'IsCetak', 'description': 'Print record'},
        'export': {'delphi': 'IsExcel', 'description': 'Export to Excel'},
        'authorize': {'delphi': None, 'description': 'Authorize/approve record'},
        'cancel': {'delphi': None, 'description': 'Cancel record'},
    }
    
    def __init__(self, model_name: str, module_name: str):
        self.model_name = model_name
        self.module_name = module_name.lower()
        
        # Detected permissions from Delphi
        self.detected_permissions: Dict[str, str] = {}
        
        # Custom authorization logic
        self.custom_checks: Dict[str, List[str]] = {}
        
        # Roles configuration
        self.admin_roles: List[str] = ['admin']
        self.allowed_roles: Dict[str, List[str]] = {}
        
    def add_permission(self, delphi_name: str, laravel_permission: str):
        """Add detected permission from Delphi"""
        self.detected_permissions[delphi_name] = laravel_permission
    
    def add_custom_check(self, method: str, check: str):
        """Add custom authorization check to a method"""
        if method not in self.custom_checks:
            self.custom_checks[method] = []
        self.custom_checks[method].append(check)
    
    def set_allowed_roles(self, method: str, roles: List[str]):
        """Set allowed roles for a method"""
        self.allowed_roles[method] = roles
    
    def generate(self) -> str:
        """Generate complete Policy class"""
        
        methods = []
        
        # Generate standard CRUD methods
        for method_name, config in self.STANDARD_METHODS.items():
            methods.append(self._generate_method(method_name, config))
        
        # Generate additional methods if permissions detected
        for method_name, config in self.ADDITIONAL_METHODS.items():
            if config['delphi'] and config['delphi'] in self.detected_permissions:
                methods.append(self._generate_method(method_name, config))
        
        methods_str = '\n'.join(methods)
        
        return f'''<?php

namespace App\\Policies;

use App\\Models\\{self.model_name};
use App\\Models\\User;
use Illuminate\\Auth\\Access\\HandlesAuthorization;

/**
 * {self.model_name}Policy
 * 
 * Authorization policy for {self.model_name} model
 * 
 * Delphi permission mapping:
 *   - IsTambah  → create()
 *   - IsKoreksi → update()
 *   - IsHapus   → delete()
 *   - IsCetak   → print()
 *   - IsExcel   → export()
 * 
 * @see \\App\\Http\\Controllers\\{self.model_name}Controller
 */
class {self.model_name}Policy
{{
    use HandlesAuthorization;

    /**
     * Admin roles that bypass all checks
     */
    private const ADMIN_ROLES = [{self._format_roles(self.admin_roles)}];

    /**
     * Perform pre-authorization checks.
     * 
     * Admins can do anything
     */
    public function before(User $user, string $ability): ?bool
    {{
        if (in_array($user->role, self::ADMIN_ROLES)) {{
            return true;
        }}

        return null; // Fall through to specific policy method
    }}

{methods_str}
}}
'''
    
    def _generate_method(self, method_name: str, config: Dict[str, Any]) -> str:
        """Generate a single policy method"""
        delphi_perm = config.get('delphi')
        description = config.get('description', '')
        
        # Determine parameters
        if method_name in ['viewAny', 'create']:
            params = 'User $user'
            model_param = ''
        else:
            params = f'User $user, {self.model_name} ${self.module_name}'
            model_param = f'${self.module_name}'
        
        # Build permission check
        permission_check = self._build_permission_check(method_name, delphi_perm)
        
        # Build role check
        role_check = self._build_role_check(method_name, model_param)
        
        # Build custom checks
        custom_checks = self._build_custom_checks(method_name, model_param)
        
        # Build return logic
        return_logic = self._build_return_logic(method_name, permission_check, role_check, custom_checks)
        
        # Delphi reference comment
        delphi_ref = f"\n     * Delphi equivalent: {delphi_perm} permission check" if delphi_perm else ""
        
        return f'''
    /**
     * Determine whether the user can {description.lower()}.
     *{delphi_ref}
     */
    public function {method_name}({params}): bool
    {{
{return_logic}
    }}
'''
    
    def _build_permission_check(self, method_name: str, delphi_perm: Optional[str]) -> str:
        """Build permission-based check"""
        if delphi_perm and delphi_perm in self.detected_permissions:
            laravel_perm = self.detected_permissions[delphi_perm]
            return f"$user->hasPermission('{laravel_perm}')"
        
        # Default permission names
        default_perms = {
            'viewAny': f'view-{self.module_name}',
            'view': f'view-{self.module_name}',
            'create': f'create-{self.module_name}',
            'update': f'update-{self.module_name}',
            'delete': f'delete-{self.module_name}',
            'restore': f'restore-{self.module_name}',
            'forceDelete': f'force-delete-{self.module_name}',
            'print': f'print-{self.module_name}',
            'export': f'export-{self.module_name}',
            'authorize': f'authorize-{self.module_name}',
            'cancel': f'cancel-{self.module_name}',
        }
        
        perm = default_perms.get(method_name, f'{method_name}-{self.module_name}')
        return f"$user->hasPermission('{perm}')"
    
    def _build_role_check(self, method_name: str, model_param: str) -> str:
        """Build role-based check"""
        if method_name in self.allowed_roles:
            roles = self.allowed_roles[method_name]
            roles_str = self._format_roles(roles)
            return f"in_array($user->role, [{roles_str}])"
        
        return ""
    
    def _build_custom_checks(self, method_name: str, model_param: str) -> List[str]:
        """Build custom authorization checks"""
        checks = []
        
        if method_name in self.custom_checks:
            for check in self.custom_checks[method_name]:
                # Replace placeholders
                check = check.replace('{model}', model_param)
                checks.append(check)
        
        # Add common checks based on method
        if method_name == 'update' and model_param:
            checks.append(f"// Cannot update if cancelled\n        if ({model_param}->is_cancelled) {{\n            return false;\n        }}")
        
        if method_name == 'delete' and model_param:
            checks.append(f"// Cannot delete if already authorized\n        if ({model_param}->is_authorized) {{\n            return false;\n        }}")
        
        return checks
    
    def _build_return_logic(self, method_name: str, permission_check: str, 
                           role_check: str, custom_checks: List[str]) -> str:
        """Build the complete return logic"""
        lines = []
        
        # Add custom checks first (they return false early)
        for check in custom_checks:
            lines.append(f"        {check}")
        
        if lines:
            lines.append("")
        
        # For simple view operations
        if method_name in ['viewAny', 'view']:
            lines.append("        // All authenticated users can view")
            lines.append("        return true;")
            return '\n'.join(lines)
        
        # For other operations - combine permission and role checks
        conditions = []
        
        if permission_check:
            conditions.append(permission_check)
        
        if role_check:
            conditions.append(role_check)
        
        if conditions:
            combined = ' && '.join(conditions) if len(conditions) > 1 else conditions[0]
            lines.append(f"        return {combined};")
        else:
            lines.append("        return true;")
        
        return '\n'.join(lines)
    
    def _format_roles(self, roles: List[str]) -> str:
        """Format roles list for PHP"""
        return ', '.join([f"'{r}'" for r in roles])


def create_from_parser_result(parser_result: Dict[str, Any], model_name: str) -> LaravelPolicyGenerator:
    """Create PolicyGenerator from parser result"""
    module_name = parser_result.get('unit_name', model_name)
    
    # Remove common prefixes
    for prefix in ['Frm', 'frm', 'Fr', 'fr', 'Form']:
        if module_name.startswith(prefix):
            module_name = module_name[len(prefix):]
            break
    
    generator = LaravelPolicyGenerator(model_name, module_name)
    
    # Add detected permissions
    for perm in parser_result.get('permission_checks', []):
        generator.add_permission(perm.name, perm.laravel_permission)
    
    return generator


if __name__ == "__main__":
    # Test the generator
    generator = LaravelPolicyGenerator('Aktiva', 'aktiva')
    
    # Add detected permissions
    generator.add_permission('IsTambah', 'create-aktiva')
    generator.add_permission('IsKoreksi', 'update-aktiva')
    generator.add_permission('IsHapus', 'delete-aktiva')
    generator.add_permission('IsCetak', 'print-aktiva')
    generator.add_permission('IsExcel', 'export-aktiva')
    
    # Add custom checks
    generator.add_custom_check('update', '// Check department ownership\n        if ($user->department_id !== {model}->department_id) {\n            return false;\n        }')
    
    # Set allowed roles
    generator.set_allowed_roles('delete', ['admin', 'manager'])
    
    print(generator.generate())
