@extends('layouts.laporan.base')

@section('title', 'DAPEN ERP - Sistem Laporan')

@section('content')
    <div class="content-header">
        <h1 class="content-title">Sistem Laporan</h1>
        <p class="content-subtitle">Pilih laporan dari tree navigasi untuk memulai</p>
    </div>

    {{-- Filters Component --}}
    <x-laporan.filters :reports="$reports" />

    {{-- Export Options Component --}}
    <x-laporan.export-options />

    {{-- Report Selection Component --}}
    <x-laporan.report-selection />
@endsection