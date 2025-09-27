{{--
    Reusable Form Field Component

    Usage:
    <x-form-field
        name="username"
        label="Username"
        type="text"
        :value="old('username')"
        required
        help="Enter your username"
    />

    <x-form-field
        name="status"
        label="Status"
        type="select"
        :options="['1' => 'Active', '0' => 'Inactive']"
        :value="old('status')"
    />
--}}

@props([
    'name' => '',
    'label' => '',
    'type' => 'text',
    'value' => '',
    'placeholder' => '',
    'help' => '',
    'required' => false,
    'disabled' => false,
    'readonly' => false,
    'options' => [],
    'multiple' => false,
    'rows' => 3,
    'size' => 'md', // sm, md, lg
    'icon' => null,
    'addon' => null,
    'class' => '',
    'containerClass' => '',
    'labelClass' => ''
])

@php
    $hasError = $errors->has($name);
    $fieldId = $name . '_' . uniqid();
    $sizeClass = $size === 'sm' ? 'form-control-sm' : ($size === 'lg' ? 'form-control-lg' : '');
@endphp

<div class="mb-3 {{ $containerClass }}">
    {{-- Label --}}
    @if($label)
    <label for="{{ $fieldId }}" class="form-label {{ $labelClass }}">
        {{ $label }}
        @if($required)
            <span class="text-danger">*</span>
        @endif
    </label>
    @endif

    {{-- Input Group Wrapper --}}
    @if($icon || $addon)
    <div class="input-group">
        @if($icon)
        <span class="input-group-text">
            <i class="{{ $icon }}"></i>
        </span>
        @endif
    @endif

    {{-- Form Control --}}
    @switch($type)
        @case('select')
            <select
                name="{{ $name }}{{ $multiple ? '[]' : '' }}"
                id="{{ $fieldId }}"
                class="form-select {{ $sizeClass }} {{ $hasError ? 'is-invalid' : '' }} {{ $class }}"
                {{ $required ? 'required' : '' }}
                {{ $disabled ? 'disabled' : '' }}
                {{ $multiple ? 'multiple' : '' }}
                {{ $attributes->except(['name', 'id', 'class', 'required', 'disabled', 'multiple']) }}
            >
                @if(!$multiple && !$required)
                    <option value="">-- Select {{ $label ?: $name }} --</option>
                @endif

                @foreach($options as $optionValue => $optionLabel)
                    @if(is_array($optionLabel))
                        <optgroup label="{{ $optionValue }}">
                            @foreach($optionLabel as $subValue => $subLabel)
                                <option
                                    value="{{ $subValue }}"
                                    {{ (is_array($value) ? in_array($subValue, $value) : $subValue == $value) ? 'selected' : '' }}
                                >
                                    {{ $subLabel }}
                                </option>
                            @endforeach
                        </optgroup>
                    @else
                        <option
                            value="{{ $optionValue }}"
                            {{ (is_array($value) ? in_array($optionValue, $value) : $optionValue == $value) ? 'selected' : '' }}
                        >
                            {{ $optionLabel }}
                        </option>
                    @endif
                @endforeach
            </select>
            @break

        @case('textarea')
            <textarea
                name="{{ $name }}"
                id="{{ $fieldId }}"
                rows="{{ $rows }}"
                class="form-control {{ $sizeClass }} {{ $hasError ? 'is-invalid' : '' }} {{ $class }}"
                placeholder="{{ $placeholder ?: $label }}"
                {{ $required ? 'required' : '' }}
                {{ $disabled ? 'disabled' : '' }}
                {{ $readonly ? 'readonly' : '' }}
                {{ $attributes->except(['name', 'id', 'rows', 'class', 'placeholder', 'required', 'disabled', 'readonly']) }}
            >{{ $value }}</textarea>
            @break

        @case('checkbox')
            <div class="form-check">
                <input
                    type="checkbox"
                    name="{{ $name }}"
                    id="{{ $fieldId }}"
                    value="1"
                    class="form-check-input {{ $hasError ? 'is-invalid' : '' }} {{ $class }}"
                    {{ $value ? 'checked' : '' }}
                    {{ $required ? 'required' : '' }}
                    {{ $disabled ? 'disabled' : '' }}
                    {{ $attributes->except(['name', 'id', 'value', 'class', 'checked', 'required', 'disabled']) }}
                >
                <label class="form-check-label" for="{{ $fieldId }}">
                    {{ $label }}
                    @if($required)
                        <span class="text-danger">*</span>
                    @endif
                </label>
            </div>
            @break

        @case('radio')
            @foreach($options as $optionValue => $optionLabel)
            <div class="form-check">
                <input
                    type="radio"
                    name="{{ $name }}"
                    id="{{ $fieldId }}_{{ $loop->index }}"
                    value="{{ $optionValue }}"
                    class="form-check-input {{ $hasError ? 'is-invalid' : '' }} {{ $class }}"
                    {{ $optionValue == $value ? 'checked' : '' }}
                    {{ $required ? 'required' : '' }}
                    {{ $disabled ? 'disabled' : '' }}
                >
                <label class="form-check-label" for="{{ $fieldId }}_{{ $loop->index }}">
                    {{ $optionLabel }}
                </label>
            </div>
            @endforeach
            @break

        @case('file')
            <input
                type="file"
                name="{{ $name }}{{ $multiple ? '[]' : '' }}"
                id="{{ $fieldId }}"
                class="form-control {{ $sizeClass }} {{ $hasError ? 'is-invalid' : '' }} {{ $class }}"
                {{ $required ? 'required' : '' }}
                {{ $disabled ? 'disabled' : '' }}
                {{ $multiple ? 'multiple' : '' }}
                {{ $attributes->except(['name', 'id', 'class', 'required', 'disabled', 'multiple']) }}
            >
            @break

        @case('password')
            <div class="position-relative">
                <input
                    type="password"
                    name="{{ $name }}"
                    id="{{ $fieldId }}"
                    class="form-control {{ $sizeClass }} {{ $hasError ? 'is-invalid' : '' }} {{ $class }}"
                    placeholder="{{ $placeholder ?: $label }}"
                    value="{{ $value }}"
                    {{ $required ? 'required' : '' }}
                    {{ $disabled ? 'disabled' : '' }}
                    {{ $readonly ? 'readonly' : '' }}
                    {{ $attributes->except(['name', 'id', 'type', 'class', 'placeholder', 'value', 'required', 'disabled', 'readonly']) }}
                >
                <button
                    type="button"
                    class="btn btn-link position-absolute end-0 top-50 translate-middle-y pe-3"
                    onclick="togglePassword('{{ $fieldId }}')"
                    style="border: none; background: none; z-index: 10;"
                >
                    <i class="fas fa-eye" id="{{ $fieldId }}_toggle"></i>
                </button>
            </div>
            @break

        @default
            <input
                type="{{ $type }}"
                name="{{ $name }}"
                id="{{ $fieldId }}"
                class="form-control {{ $sizeClass }} {{ $hasError ? 'is-invalid' : '' }} {{ $class }}"
                placeholder="{{ $placeholder ?: $label }}"
                value="{{ $value }}"
                {{ $required ? 'required' : '' }}
                {{ $disabled ? 'disabled' : '' }}
                {{ $readonly ? 'readonly' : '' }}
                {{ $attributes->except(['name', 'id', 'type', 'class', 'placeholder', 'value', 'required', 'disabled', 'readonly']) }}
            >
    @endswitch

    {{-- Close Input Group --}}
    @if($addon)
        <span class="input-group-text">{{ $addon }}</span>
    @endif

    @if($icon || $addon)
    </div>
    @endif

    {{-- Error Message --}}
    @if($hasError)
    <div class="invalid-feedback">
        {{ $errors->first($name) }}
    </div>
    @endif

    {{-- Help Text --}}
    @if($help && !$hasError)
    <div class="form-text">{{ $help }}</div>
    @endif
</div>

@if($type === 'password')
@push('scripts')
<script>
function togglePassword(fieldId) {
    const field = document.getElementById(fieldId);
    const toggle = document.getElementById(fieldId + '_toggle');

    if (field.type === 'password') {
        field.type = 'text';
        toggle.classList.remove('fa-eye');
        toggle.classList.add('fa-eye-slash');
    } else {
        field.type = 'password';
        toggle.classList.remove('fa-eye-slash');
        toggle.classList.add('fa-eye');
    }
}
</script>
@endpush
@endif

@push('styles')
<style>
.form-label {
    font-weight: 500;
    color: #495057;
    margin-bottom: 0.5rem;
}

.form-control:focus,
.form-select:focus {
    border-color: #007bff;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.form-control.is-invalid:focus,
.form-select.is-invalid:focus {
    border-color: #dc3545;
    box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
}

.form-check-input:focus {
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.input-group-text {
    background-color: #f8f9fa;
    border-color: #ced4da;
    color: #6c757d;
}

.form-text {
    color: #6c757d;
    font-size: 0.875rem;
    margin-top: 0.25rem;
}

/* Required field indicator */
.text-danger {
    color: #dc3545 !important;
}

/* File input styling */
.form-control[type="file"] {
    padding: 0.375rem 0.75rem;
}

/* Password toggle button */
.btn-link {
    color: #6c757d;
    text-decoration: none;
}

.btn-link:hover {
    color: #495057;
}

.btn-link:focus {
    box-shadow: none;
}
</style>
@endpush