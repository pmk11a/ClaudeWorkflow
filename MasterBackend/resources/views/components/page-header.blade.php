{{--
    Reusable Page Header Component

    Usage:
    <x-page-header
        title="User Management"
        subtitle="Manage system users and their access"
        icon="fas fa-users"
    >
        <x-slot name="actions">
            <a href="{{ route('users.create') }}" class="btn btn-primary">
                <i class="fas fa-plus"></i> Add User
            </a>
        </x-slot>
    </x-page-header>
--}}

@props([
    'title' => 'Page Title',
    'subtitle' => null,
    'icon' => null,
    'breadcrumbs' => []
])

<div class="page-header mb-4">
    {{-- Breadcrumbs --}}
    @if(!empty($breadcrumbs))
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            @foreach($breadcrumbs as $breadcrumb)
                @if($loop->last)
                    <li class="breadcrumb-item active" aria-current="page">
                        {{ $breadcrumb['title'] }}
                    </li>
                @else
                    <li class="breadcrumb-item">
                        @if(isset($breadcrumb['url']))
                            <a href="{{ $breadcrumb['url'] }}">{{ $breadcrumb['title'] }}</a>
                        @else
                            {{ $breadcrumb['title'] }}
                        @endif
                    </li>
                @endif
            @endforeach
        </ol>
    </nav>
    @endif

    {{-- Header Content --}}
    <div class="d-flex justify-content-between align-items-start">
        <div class="page-title">
            <h1 class="h3 mb-0 d-flex align-items-center">
                @if($icon)
                    <i class="{{ $icon }} me-2"></i>
                @endif
                {{ $title }}
            </h1>

            @if($subtitle)
                <p class="text-muted mb-0 mt-1">{{ $subtitle }}</p>
            @endif
        </div>

        {{-- Action Buttons --}}
        @if(isset($actions))
            <div class="page-actions">
                {{ $actions }}
            </div>
        @endif
    </div>

    {{-- Additional Content Slot --}}
    @if(isset($content))
        <div class="page-header-content mt-3">
            {{ $content }}
        </div>
    @endif
</div>

@push('styles')
<style>
.page-header {
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    border-radius: 8px;
    padding: 1.5rem;
    margin-bottom: 1.5rem;
    border: 1px solid #dee2e6;
}

.page-header .page-title h1 {
    color: #495057;
    font-weight: 600;
}

.page-header .page-actions {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
}

.page-header .breadcrumb {
    background: transparent;
    padding: 0;
    margin: 0;
}

.page-header .breadcrumb-item + .breadcrumb-item::before {
    color: #6c757d;
}

@media (max-width: 768px) {
    .page-header {
        padding: 1rem;
    }

    .page-header .d-flex {
        flex-direction: column;
        align-items: stretch !important;
    }

    .page-header .page-actions {
        margin-top: 1rem;
        justify-content: stretch;
    }

    .page-header .page-actions .btn {
        flex: 1;
    }
}
</style>
@endpush