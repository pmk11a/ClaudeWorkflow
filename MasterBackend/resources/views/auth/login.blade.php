<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DAPEN Login</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    @include('layouts.partials.auth-styles')
</head>
<body class="auth-page">
    <div class="login-container">
        @include('auth.partials.login-header')
        @include('auth.partials.login-form')
        @include('auth.partials.login-footer')
    </div>

    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="spinner"></div>
    </div>

    <!-- Custom JavaScript -->
    <script src="{{ asset('js/auth.js') }}"></script>

    <!-- Clean flash messages component -->
    <x-flash-messages />
</body>
</html>