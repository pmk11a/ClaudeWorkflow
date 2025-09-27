<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'DAPEN ERP - Sistem Laporan')</title>

    {{-- Base Laporan Styles --}}
    <link href="{{ asset('css/laporan/dashboard.css') }}" rel="stylesheet">

    {{-- Additional Styles --}}
    @stack('styles')
</head>
<body>
    {{-- Header Component --}}
    <x-laporan.header :user="$user" />

    <div class="container">
        {{-- Sidebar Component --}}
        <x-laporan.sidebar :reports="$reports" />

        {{-- Main Content --}}
        <div class="main-content" id="mainContent">
            @yield('content')
        </div>
    </div>

    {{-- Base Laporan Scripts --}}
    <script src="{{ asset('js/laporan/dashboard.js') }}"></script>

    {{-- Additional Scripts --}}
    @stack('scripts')
</body>
</html>