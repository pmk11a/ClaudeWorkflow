@extends('layouts.admin')

@section('title', 'Dashboard')

@section('content')
<x-page-header
    title="Dashboard"
    subtitle="Welcome to DAPEN Smart Accounting System"
    icon="fas fa-tachometer-alt"
>
    <x-slot name="actions">
        <div class="d-flex gap-2">
            <span class="badge bg-success">Online</span>
            <span class="text-muted">{{ now()->format('d/m/Y H:i:s') }}</span>
        </div>
    </x-slot>
</x-page-header>

<!-- Flash Messages -->
<x-flash-messages />

<div class="row">
    <div class="col-md-8">
        <x-dashboard-welcome-info :user="$user" />
    </div>

    <div class="col-md-4">
        <x-dashboard-quick-stats :user="$user" />
    </div>
</div>

<div class="row mt-4">
    <div class="col-md-12">
        <x-dashboard-system-stats />
    </div>
</div>

<div class="row mt-4">
    <div class="col-md-12">
        <x-dashboard-system-info />
    </div>
</div>
@endsection

@push('styles')
<link href="{{ asset('css/dashboard.css') }}" rel="stylesheet">
@endpush