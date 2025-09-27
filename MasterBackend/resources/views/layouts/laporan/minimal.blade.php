<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'DAPEN ERP - Sistem Laporan')</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    {{-- Base Laporan Styles --}}
    <link href="{{ asset('css/laporan/dashboard.css') }}" rel="stylesheet">

    {{-- Additional Styles --}}
    @stack('styles')
</head>
<body>
    {{-- Main Content --}}
    @yield('content')

    {{-- Base Laporan Scripts --}}
    <script src="{{ asset('js/laporan/dashboard.js') }}"></script>

    {{-- Additional Scripts --}}
    @stack('scripts')
</body>
</html>