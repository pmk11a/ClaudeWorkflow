<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'DAPEN Admin')</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    @include('layouts.partials.admin-styles')

    <!-- Page-specific CSS -->
    @stack('styles')
</head>
<body>
    @include('layouts.partials.admin-header')
    @include('layouts.partials.admin-sidebar')

    <!-- Main Content -->
    <main class="main-content">
        <!-- Breadcrumb -->
        @if(!empty(trim($__env->yieldContent('breadcrumb'))))
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                @yield('breadcrumb')
            </ol>
        </nav>
        @endif

        <!-- Flash Messages -->
        <x-flash-messages />

        <!-- Page Content -->
        @yield('content')
    </main>

    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="spinner"></div>
    </div>

    <x-period-selector-modal />

    @include('layouts.partials.admin-scripts')
</body>
</html>