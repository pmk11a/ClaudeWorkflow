<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        // Check if authenticated user has permission to update users
        return session('user') && session('user.TINGKAT') >= 3;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules()
    {
        $userId = $this->route('user'); // Get user ID from route parameter

        return [
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
            'HOSTID' => [
                'nullable',
                'string',
                'max:50'
            ],
            'IPAddres' => [
                'nullable',
                'ip'
            ],
            'password' => [
                'nullable',
                'string',
                'min:6',
                'max:50'
            ],
            'password_confirmation' => [
                'nullable',
                'required_with:password',
                'same:password'
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
            'FullName.required' => 'Full name is required.',
            'FullName.min' => 'Full name must be at least 2 characters.',
            'TINGKAT.required' => 'User level is required.',
            'TINGKAT.min' => 'User level must be between 1 and 5.',
            'TINGKAT.max' => 'User level must be between 1 and 5.',
            'IPAddres.ip' => 'IP Address must be a valid IP address.',
            'password.min' => 'Password must be at least 6 characters.',
            'password_confirmation.required_with' => 'Password confirmation is required when changing password.',
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
            'FullName' => 'Full Name',
            'TINGKAT' => 'User Level',
            'STATUS' => 'Status',
            'kodeBag' => 'Department Code',
            'KodeJab' => 'Job Code',
            'KodeKasir' => 'Cashier Code',
            'Kodegdg' => 'Warehouse Code',
            'HOSTID' => 'Host ID',
            'IPAddres' => 'IP Address',
            'password' => 'Password',
            'password_confirmation' => 'Password Confirmation'
        ];
    }

    /**
     * Prepare the data for validation.
     *
     * @return void
     */
    protected function prepareForValidation()
    {
        // Set STATUS to boolean
        $this->merge([
            'STATUS' => $this->has('STATUS') ? true : false
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
            $currentUserId = session('user.USERID');
            $requestedLevel = $this->input('TINGKAT');
            $targetUserId = $this->route('user');

            // Users cannot update users with higher level than themselves (unless it's themselves)
            if ($targetUserId !== $currentUserId && $requestedLevel > $currentUserLevel) {
                $validator->errors()->add(
                    'TINGKAT', 
                    'You cannot set user level higher than your own level (' . $currentUserLevel . ').'
                );
            }

            // Only super admin can create/update other super admins
            if ($requestedLevel >= 5 && $currentUserLevel < 5 && $targetUserId !== $currentUserId) {
                $validator->errors()->add(
                    'TINGKAT', 
                    'Only Super Admin can set Super Admin level for other users.'
                );
            }

            // Prevent users from downgrading themselves below manager level if they are the only high-level user
            if ($targetUserId === $currentUserId && $requestedLevel < 3 && $currentUserLevel >= 3) {
                // Check if there are other high-level users
                $highLevelUserCount = \App\Models\DbFLPASS::where('TINGKAT', '>=', 3)
                    ->where('STATUS', 1)
                    ->where('USERID', '!=', $currentUserId)
                    ->count();

                if ($highLevelUserCount == 0) {
                    $validator->errors()->add(
                        'TINGKAT', 
                        'You cannot downgrade yourself as you are the only manager/admin in the system.'
                    );
                }
            }
        });
    }
}