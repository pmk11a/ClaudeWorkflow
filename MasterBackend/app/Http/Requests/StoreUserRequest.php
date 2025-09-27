<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        // Check if authenticated user has permission to create users
        return session('user') && session('user.TINGKAT') >= 3;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules()
    {
        return [
            'USERID' => [
                'required',
                'string',
                'max:20',
                'regex:/^[A-Za-z0-9_-]+$/', // Only alphanumeric, underscore, and dash
                'unique:DBFLPASS,USERID'
            ],
            'FullName' => [
                'required',
                'string',
                'max:100',
                'min:2'
            ],
            'TINGKAT' => [
                'required',
                'integer',
                'min:1',
                'max:5'
            ],
            'STATUS' => [
                'boolean'
            ],
            'kodeBag' => [
                'nullable',
                'string',
                'max:10'
            ],
            'KodeJab' => [
                'nullable',
                'string',
                'max:10'
            ],
            'KodeKasir' => [
                'nullable',
                'string',
                'max:10'
            ],
            'Kodegdg' => [
                'nullable',
                'string',
                'max:10'
            ],
            'password' => [
                'required',
                'string',
                'min:6',
                'max:50'
            ],
            'password_confirmation' => [
                'required',
                'same:password'
            ],
            'set_default_permissions' => [
                'boolean'
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
            'USERID.required' => 'User ID is required.',
            'USERID.unique' => 'This User ID is already taken.',
            'USERID.regex' => 'User ID can only contain letters, numbers, underscore, and dash.',
            'FullName.required' => 'Full name is required.',
            'FullName.min' => 'Full name must be at least 2 characters.',
            'TINGKAT.required' => 'User level is required.',
            'TINGKAT.min' => 'User level must be between 1 and 5.',
            'TINGKAT.max' => 'User level must be between 1 and 5.',
            'password.required' => 'Password is required.',
            'password.min' => 'Password must be at least 6 characters.',
            'password_confirmation.required' => 'Password confirmation is required.',
            'password_confirmation.same' => 'Password confirmation does not match.'
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
            'USERID' => 'User ID',
            'FullName' => 'Full Name',
            'TINGKAT' => 'User Level',
            'STATUS' => 'Status',
            'kodeBag' => 'Department Code',
            'KodeJab' => 'Job Code',
            'KodeKasir' => 'Cashier Code',
            'Kodegdg' => 'Warehouse Code',
            'password' => 'Password',
            'password_confirmation' => 'Password Confirmation',
            'set_default_permissions' => 'Set Default Permissions'
        ];
    }

    /**
     * Prepare the data for validation.
     *
     * @return void
     */
    protected function prepareForValidation()
    {
        // Convert USERID to uppercase
        if ($this->has('USERID')) {
            $this->merge([
                'USERID' => strtoupper($this->USERID)
            ]);
        }

        // Set STATUS to boolean
        $this->merge([
            'STATUS' => $this->has('STATUS') ? true : false,
            'set_default_permissions' => $this->has('set_default_permissions') ? true : false
        ]);
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
            $currentUserLevel = session('user.TINGKAT', 0);
            $requestedLevel = $this->input('TINGKAT');

            // Users cannot create users with higher level than themselves
            if ($requestedLevel > $currentUserLevel) {
                $validator->errors()->add(
                    'TINGKAT', 
                    'You cannot create a user with higher level than your own level (' . $currentUserLevel . ').'
                );
            }

            // Only super admin can create other super admins
            if ($requestedLevel >= 5 && $currentUserLevel < 5) {
                $validator->errors()->add(
                    'TINGKAT', 
                    'Only Super Admin can create Super Admin users.'
                );
            }
        });
    }
}