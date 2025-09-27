# Component Patterns Library

🧩 **Reusable Laravel Blade component patterns untuk clean code architecture**

## 🎯 Component Design Principles

### Single Responsibility
Each component should have one clear, focused purpose.

### Prop Interface
Components should have clean, predictable prop interfaces.

### Reusability
Components should work across different contexts without modification.

## 📊 Dashboard Component Suite

### Welcome Info Component
```blade
<!-- resources/views/components/dashboard-welcome-info.blade.php -->
@props(['user'])
<x-card title="Welcome Information" icon="fas fa-info-circle">
    <div class="welcome-info">
        <h4>🎉 Login Successful!</h4>
        <p class="text-muted mb-3">Welcome to DAPEN Smart Accounting System</p>

        <div class="row">
            <div class="col-md-6">
                <ul class="list-unstyled">
                    <li><strong>Username:</strong> {{ $user->USERID }}</li>
                    <li><strong>Full Name:</strong> {{ $user->FullName }}</li>
                    <li><strong>Level:</strong> {{ $user->TINGKAT }} ({{ $user->getUserLevelName() }})</li>
                </ul>
            </div>
            <div class="col-md-6">
                <ul class="list-unstyled">
                    <li><strong>Department:</strong> {{ $user->kodeBag ?? 'N/A' }}</li>
                    <li><strong>Position:</strong> {{ $user->KodeJab ?? 'N/A' }}</li>
                    <li><strong>Last Login:</strong> Current session</li>
                </ul>
            </div>
        </div>
    </div>
</x-card>
```

### Quick Stats Component
```blade
<!-- resources/views/components/dashboard-quick-stats.blade.php -->
@props(['user'])
<x-card title="Quick Stats" icon="fas fa-chart-bar">
    <div class="stats-list">
        <div class="stat-item d-flex justify-content-between">
            <span>Session:</span>
            <span class="badge bg-primary">Active</span>
        </div>
        <div class="stat-item d-flex justify-content-between">
            <span>User Level:</span>
            <span class="badge bg-info">{{ $user->getUserLevelName() }}</span>
        </div>
        <div class="stat-item d-flex justify-content-between">
            <span>Status:</span>
            <span class="badge bg-{{ $user->isActive() ? 'success' : 'danger' }}">
                {{ $user->isActive() ? 'Active' : 'Inactive' }}
            </span>
        </div>
    </div>
</x-card>
```

### System Statistics Component
```blade
<!-- resources/views/components/dashboard-system-stats.blade.php -->
<x-card title="System Statistics" icon="fas fa-database">
    <div class="row text-center">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number text-primary">235+</div>
                <div class="stat-label">Database Models</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number text-success">100+</div>
                <div class="stat-label">ERP Tables</div>
            </div>
        </div>
    </div>
</x-card>
```

## 🔧 Form Components

### Form Field Component
```blade
<!-- resources/views/components/form-field.blade.php -->
@props([
    'name',
    'label',
    'type' => 'text',
    'placeholder' => '',
    'required' => false,
    'value' => null
])

<div class="form-group">
    <label for="{{ $name }}" class="form-label">
        {{ $label }}
        @if($required)<span class="text-danger">*</span>@endif
    </label>

    <input
        type="{{ $type }}"
        id="{{ $name }}"
        name="{{ $name }}"
        class="form-control @error($name) is-invalid @enderror"
        placeholder="{{ $placeholder }}"
        value="{{ old($name, $value) }}"
        {{ $required ? 'required' : '' }}
        {{ $attributes }}
    >

    @error($name)
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>
```

### Select Field Component
```blade
<!-- resources/views/components/select-field.blade.php -->
@props([
    'name',
    'label',
    'options' => [],
    'selected' => null,
    'placeholder' => 'Select an option',
    'required' => false
])

<div class="form-group">
    <label for="{{ $name }}" class="form-label">
        {{ $label }}
        @if($required)<span class="text-danger">*</span>@endif
    </label>

    <select
        id="{{ $name }}"
        name="{{ $name }}"
        class="form-select @error($name) is-invalid @enderror"
        {{ $required ? 'required' : '' }}
        {{ $attributes }}
    >
        @if($placeholder)
            <option value="">{{ $placeholder }}</option>
        @endif

        @foreach($options as $value => $text)
            <option value="{{ $value }}" {{ old($name, $selected) == $value ? 'selected' : '' }}>
                {{ $text }}
            </option>
        @endforeach
    </select>

    @error($name)
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>
```

## 📄 Layout Components

### Page Header Component
```blade
<!-- resources/views/components/page-header.blade.php -->
@props(['title', 'subtitle' => '', 'icon' => '', 'breadcrumbs' => []])

<div class="page-header">
    <div class="row">
        <div class="col-md-6">
            <h1 class="page-title">
                @if($icon)<i class="{{ $icon }} me-2"></i>@endif
                {{ $title }}
            </h1>
            @if($subtitle)
                <p class="page-subtitle text-muted">{{ $subtitle }}</p>
            @endif
        </div>
        <div class="col-md-6">
            <div class="page-actions">
                {{ $actions ?? '' }}
            </div>
        </div>
    </div>

    @if($breadcrumbs)
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                @foreach($breadcrumbs as $crumb)
                    <li class="breadcrumb-item">
                        @if(isset($crumb['url']))
                            <a href="{{ $crumb['url'] }}">{{ $crumb['title'] }}</a>
                        @else
                            {{ $crumb['title'] }}
                        @endif
                    </li>
                @endforeach
            </ol>
        </nav>
    @endif
</div>
```

### Card Component
```blade
<!-- resources/views/components/card.blade.php -->
@props(['title' => '', 'icon' => '', 'class' => ''])

<div class="card {{ $class }}">
    @if($title)
        <div class="card-header">
            <h5 class="card-title mb-0">
                @if($icon)<i class="{{ $icon }} me-2"></i>@endif
                {{ $title }}
            </h5>
            @if(isset($actions))
                <div class="card-actions">
                    {{ $actions }}
                </div>
            @endif
        </div>
    @endif

    <div class="card-body">
        {{ $slot }}
    </div>

    @if(isset($footer))
        <div class="card-footer">
            {{ $footer }}
        </div>
    @endif
</div>
```

## 🚨 Alert Components

### Flash Messages Component
```blade
<!-- resources/views/components/flash-messages.blade.php -->
@if(session()->has('error') || session()->has('success') || $errors->any())
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const flashMessages = {
            @if(session('error'))error: @json(session('error')),@endif
            @if(session('success'))success: @json(session('success')),@endif
            @if($errors->any())errors: @json($errors->all()),@endif
        };

        if (window.DapenAuth && typeof window.DapenAuth.processFlashMessages === 'function') {
            window.DapenAuth.processFlashMessages(flashMessages);
        }
    });
</script>
@endif
```

### Alert Component
```blade
<!-- resources/views/components/alert.blade.php -->
@props(['type' => 'info', 'dismissible' => false, 'icon' => ''])

@php
$typeClasses = [
    'success' => 'alert-success',
    'error' => 'alert-danger',
    'warning' => 'alert-warning',
    'info' => 'alert-info'
];
$class = $typeClasses[$type] ?? 'alert-info';
@endphp

<div class="alert {{ $class }} {{ $dismissible ? 'alert-dismissible fade show' : '' }}" role="alert">
    @if($icon)
        <i class="{{ $icon }} me-2"></i>
    @endif

    {{ $slot }}

    @if($dismissible)
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    @endif
</div>
```

## 📊 Data Components

### Data Table Component
```blade
<!-- resources/views/components/data-table.blade.php -->
@props(['headers' => [], 'rows' => [], 'class' => ''])

<div class="table-responsive">
    <table class="table {{ $class }}">
        @if($headers)
            <thead>
                <tr>
                    @foreach($headers as $header)
                        <th>{{ $header }}</th>
                    @endforeach
                </tr>
            </thead>
        @endif

        <tbody>
            @forelse($rows as $row)
                <tr>
                    @foreach($row as $cell)
                        <td>{{ $cell }}</td>
                    @endforeach
                </tr>
            @empty
                <tr>
                    <td colspan="{{ count($headers) }}" class="text-center text-muted">
                        No data available
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>
```

## 🎯 Usage Examples

### Dashboard Page
```blade
@extends('layouts.admin')

@section('content')
<x-page-header
    title="Dashboard"
    subtitle="Welcome to DAPEN Smart Accounting"
    icon="fas fa-tachometer-alt"
>
    <x-slot name="actions">
        <div class="d-flex gap-2">
            <span class="badge bg-success">Online</span>
            <span class="text-muted">{{ now()->format('d/m/Y H:i:s') }}</span>
        </div>
    </x-slot>
</x-page-header>

<x-flash-messages />

<div class="row">
    <div class="col-md-8">
        <x-dashboard-welcome-info :user="$user" />
    </div>
    <div class="col-md-4">
        <x-dashboard-quick-stats :user="$user" />
    </div>
</div>
@endsection
```

### Form Page
```blade
@extends('layouts.admin')

@section('content')
<x-page-header title="User Profile" icon="fas fa-user" />

<x-card title="Edit Profile">
    <form method="POST" action="{{ route('profile.update') }}">
        @csrf

        <x-form-field
            name="name"
            label="Full Name"
            :value="$user->name"
            required
        />

        <x-form-field
            name="email"
            label="Email"
            type="email"
            :value="$user->email"
            required
        />

        <x-select-field
            name="department"
            label="Department"
            :options="$departments"
            :selected="$user->department_id"
            placeholder="Choose department"
        />

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Save Changes</button>
            <a href="{{ route('dashboard') }}" class="btn btn-secondary">Cancel</a>
        </div>
    </form>
</x-card>
@endsection
```

---

**🎯 Component Benefits:**
- ✅ **Consistent UI** across application
- ✅ **Maintainable code** with centralized components
- ✅ **Developer efficiency** with reusable patterns
- ✅ **Type safety** with prop validation