<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePermissionRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        // Check if authenticated user has permission to manage permissions
        return session('user') && session('user.TINGKAT') >= 4;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules()
    {
        return [
            'menu_code' => [
                'required',
                'string',
                'exists:DBMENU,KODEMENU'
            ],
            'permissions' => [
                'required',
                'array'
            ],
            'permissions.has_access' => [
                'boolean'
            ],
            'permissions.add' => [
                'boolean'
            ],
            'permissions.edit' => [
                'boolean'
            ],
            'permissions.delete' => [
                'boolean'
            ],
            'permissions.print' => [
                'boolean'
            ],
            'permissions.export' => [
                'boolean'
            ],
            'permissions.type' => [
                'nullable',
                'string',
                'max:20'
            ]
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array
     */
    public function messages()
    {
        return [
            'menu_code.required' => 'Menu code is required.',
            'menu_code.exists' => 'Selected menu does not exist.',
            'permissions.required' => 'Permissions data is required.',
            'permissions.array' => 'Permissions must be an array.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     *
     * @return array
     */
    public function attributes()
    {
        return [
            'menu_code' => 'Menu Code',
            'permissions.has_access' => 'Access Permission',
            'permissions.add' => 'Add Permission',
            'permissions.edit' => 'Edit Permission',
            'permissions.delete' => 'Delete Permission',
            'permissions.print' => 'Print Permission',
            'permissions.export' => 'Export Permission',
            'permissions.type' => 'Permission Type'
        ];
    }

    /**
     * Prepare the data for validation.
     *
     * @return void
     */
    protected function prepareForValidation()
    {
        // Ensure all permission values are boolean
        if ($this->has('permissions')) {
            $permissions = $this->input('permissions');
            
            $booleanFields = ['has_access', 'add', 'edit', 'delete', 'print', 'export'];
            
            foreach ($booleanFields as $field) {
                if (isset($permissions[$field])) {
                    $permissions[$field] = filter_var($permissions[$field], FILTER_VALIDATE_BOOLEAN);
                }
            }
            
            $this->merge(['permissions' => $permissions]);
        }
    }

    /**
     * Configure the validator instance.
     *
     * @param  \Illuminate\Validation\Validator  $validator
     * @return void
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            $permissions = $this->input('permissions', []);
            
            // If user doesn't have access, they shouldn't have other permissions
            if (isset($permissions['has_access']) && !$permissions['has_access']) {
                $otherPermissions = ['add', 'edit', 'delete', 'print', 'export'];
                $hasOtherPermissions = false;
                
                foreach ($otherPermissions as $perm) {
                    if (isset($permissions[$perm]) && $permissions[$perm]) {
                        $hasOtherPermissions = true;
                        break;
                    }
                }
                
                if ($hasOtherPermissions) {
                    $validator->errors()->add(
                        'permissions', 
                        'User cannot have specific permissions without basic access to the menu.'
                    );
                }
            }
            
            // Only super admin can grant delete permissions for critical menus
            $currentUserLevel = session('user.TINGKAT', 0);
            if (isset($permissions['delete']) && $permissions['delete'] && $currentUserLevel < 5) {
                // Define critical menus that only super admin can grant delete permission
                $criticalMenus = ['USER', 'PERMISSION', 'SYSTEM', 'CONFIG'];
                $menuCode = $this->input('menu_code');
                
                if (in_array(strtoupper($menuCode), $criticalMenus)) {
                    $validator->errors()->add(
                        'permissions.delete', 
                        'Only Super Admin can grant delete permission for this menu.'
                    );
                }
            }
        });
    }
}