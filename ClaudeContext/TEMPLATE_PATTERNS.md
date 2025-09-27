# Template Patterns Library

🎯 **Detailed clean code template patterns untuk Laravel Blade templates**

## 🧩 Main Template Structure Pattern

```blade
<!-- Standard clean template structure -->
<!DOCTYPE html>
<html lang="en">
<head>
    @include('layouts.partials.module-styles')
</head>
<body>
    <div class="container">
        @include('module.partials.header')
        @include('module.partials.main-content')
        @include('module.partials.footer')
    </div>

    <script src="{{ asset('js/module.js') }}"></script>
    <x-flash-messages />
</body>
</html>
```

## 💬 Flash Messages Pattern

```blade
<!-- Reusable flash messages component -->
<!-- resources/views/components/flash-messages.blade.php -->
@if(session()->has('error') || session()->has('success') || $errors->any())
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const flashMessages = {
            @if(session('error'))error: @json(session('error')),@endif
            @if(session('success'))success: @json(session('success')),@endif
            @if($errors->any())errors: @json($errors->all()),@endif
        };
        if (window.ModuleName && typeof window.ModuleName.processFlashMessages === 'function') {
            window.ModuleName.processFlashMessages(flashMessages);
        }
    });
</script>
@endif

<!-- Usage anywhere -->
<x-flash-messages />
```

## 📊 Dashboard Component Suite

```blade
<!-- Dashboard welcome info component -->
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
                </ul>
            </div>
        </div>
    </div>
</x-card>

<!-- Usage in dashboard template -->
<x-dashboard-welcome-info :user="$user" />
<x-dashboard-quick-stats :user="$user" />
<x-dashboard-system-stats />
<x-dashboard-system-info />
```

## 🎨 Asset Management Patterns

```blade
<!-- Centralized style partials -->
<!-- layouts/partials/auth-styles.blade.php -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="{{ asset('css/auth.css') }}" rel="stylesheet">

<!-- layouts/partials/dashboard-styles.blade.php -->
<link href="{{ asset('css/dashboard.css') }}" rel="stylesheet">

<!-- Usage in templates -->
@extends('layouts.admin')
@section('content')
    <!-- content here -->
@endsection

@push('styles')
@include('layouts.partials.dashboard-styles')
@endpush
```

## 🔧 Component Prop Patterns

```blade
<!-- Component with required props -->
@props(['user', 'title' => 'Default Title'])
<div class="user-card">
    <h3>{{ $title }}</h3>
    <p>Welcome, {{ $user->FullName }}</p>
</div>

<!-- Usage with prop passing -->
<x-user-card :user="$currentUser" title="Dashboard Welcome" />
<x-user-card :user="$currentUser" /> <!-- Uses default title -->
```

## 📝 Form Component Patterns

```blade
<!-- Reusable form field component -->
@props(['name', 'label', 'type' => 'text', 'required' => false])
<div class="form-group">
    <label for="{{ $name }}">{{ $label }}</label>
    <input
        type="{{ $type }}"
        id="{{ $name }}"
        name="{{ $name }}"
        class="form-control @error($name) is-invalid @enderror"
        value="{{ old($name) }}"
        {{ $required ? 'required' : '' }}
    >
    @error($name)
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<!-- Usage -->
<x-form-field name="username" label="Username" required />
<x-form-field name="email" label="Email" type="email" />
```

## 🎯 Authentication Template Pattern

```blade
<!-- Clean auth template structure -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'DAPEN Auth' }}</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    @include('layouts.partials.auth-styles')
</head>
<body class="auth-page">
    <div class="auth-container">
        @include('auth.partials.header')

        <main class="auth-main">
            @yield('content')
        </main>

        @include('auth.partials.footer')
    </div>

    @include('layouts.partials.auth-scripts')
    <x-flash-messages />
</body>
</html>
```

## 🔄 Refactoring Before/After Examples

### Before: Mixed Concerns
```blade
<!DOCTYPE html>
<html>
<head>
    <link href="https://cdnjs.cloudflare.com/..." rel="stylesheet">
    <style>
        .welcome { color: green; }
        .stats { padding: 1rem; }
    </style>
</head>
<body>
    <div class="welcome">
        <h1>Welcome {{ $user->name }}</h1>
        <!-- 50+ lines of mixed HTML -->
    </div>

    @if(session('error'))
    <script>alert('Error: {{ session('error') }}');</script>
    @endif
</body>
</html>
```

### After: Clean Separation
```blade
@extends('layouts.admin')
@section('content')
    <x-dashboard-welcome :user="$user" />
    <x-dashboard-stats />
@endsection

@push('styles')
<link href="{{ asset('css/dashboard.css') }}" rel="stylesheet">
@endpush
```

---

**🎯 Key Benefits:**
- ✅ **Reusable components** across application
- ✅ **Clean separation** of concerns
- ✅ **Maintainable templates** with focused responsibility
- ✅ **Consistent patterns** for team development