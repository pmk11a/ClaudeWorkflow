<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class LoginRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'username' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[a-zA-Z0-9_.-]+$/' // Only alphanumeric, underscore, dot, dash
            ],
            'password' => [
                'required',
                'string',
                'min:4',
                'max:255'
            ],
            'remember' => [
                'sometimes',
                'boolean'
            ]
        ];
    }

    /**
     * Get custom messages for validation errors.
     */
    public function messages(): array
    {
        return [
            'username.required' => 'Username is required.',
            'username.min' => 'Username must be at least 3 characters.',
            'username.max' => 'Username cannot exceed 50 characters.',
            'username.regex' => 'Username can only contain letters, numbers, underscore, dot, and dash.',
            'password.required' => 'Password is required.',
            'password.min' => 'Password must be at least 4 characters.',
            'password.max' => 'Password cannot exceed 255 characters.',
        ];
    }

    /**
     * Get the validation attributes for the request.
     */
    public function attributes(): array
    {
        return [
            'username' => 'username',
            'password' => 'password',
            'remember' => 'remember me'
        ];
    }

    /**
     * Handle a failed validation attempt.
     */
    protected function failedValidation(Validator $validator): void
    {
        if ($this->expectsJson()) {
            throw new HttpResponseException(
                response()->json([
                    'success' => false,
                    'message' => 'Validation failed.',
                    'errors' => $validator->errors()
                ], 422)
            );
        }

        parent::failedValidation($validator);
    }

    /**
     * Prepare the data for validation.
     */
    protected function prepareForValidation(): void
    {
        $this->merge([
            'username' => trim(strtoupper($this->username ?? '')), // Normalize to uppercase
            'remember' => $this->boolean('remember')
        ]);
    }

    /**
     * Get credentials for authentication
     */
    public function getCredentials(): array
    {
        return $this->only(['username', 'password']);
    }

    /**
     * Get remember me preference
     */
    public function getRememberMe(): bool
    {
        return $this->boolean('remember');
    }

    /**
     * Get safe username for logging
     */
    public function getSafeUsername(): string
    {
        $username = $this->string('username');

        // Mask username for logging (show first 2 and last 2 characters)
        if (strlen($username) <= 4) {
            return str_repeat('*', strlen($username));
        }

        return substr($username, 0, 2) . str_repeat('*', strlen($username) - 4) . substr($username, -2);
    }

    /**
     * Sanitize input to prevent injection attacks
     */
    public function getSanitizedInput(): array
    {
        return [
            'username' => filter_var($this->username, FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH),
            'password' => $this->password, // Don't sanitize password as it might change the value
            'remember' => $this->boolean('remember')
        ];
    }
}