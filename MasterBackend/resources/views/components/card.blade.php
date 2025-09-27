{{--
    Reusable Card Component

    Usage:
    <x-card title="Card Title" icon="fas fa-users">
        <x-slot name="actions">
            <button class="btn btn-sm btn-outline-primary">Action</button>
        </x-slot>

        Card content goes here...

        <x-slot name="footer">
            Footer content
        </x-slot>
    </x-card>
--}}

@props([
    'title' => null,
    'subtitle' => null,
    'icon' => null,
    'headerClass' => '',
    'bodyClass' => '',
    'footerClass' => '',
    'collapsible' => false,
    'collapsed' => false,
    'id' => null
])

<div {{ $attributes->merge(['class' => 'card']) }} @if($id) id="{{ $id }}" @endif @if($collapsible) data-collapsible="true" @endif>
    @if($title || isset($actions) || $collapsible)
    <div class="card-header {{ $headerClass }}">
        <div class="d-flex justify-content-between align-items-center">
            <div class="card-title-section">
                @if($title)
                <h5 class="card-title mb-0 d-flex align-items-center">
                    @if($icon)
                        <i class="{{ $icon }} me-2"></i>
                    @endif
                    {{ $title }}
                    @if($collapsible)
                        <button
                            type="button"
                            class="btn btn-sm btn-link ms-2 p-0"
                            data-bs-toggle="collapse"
                            data-bs-target="#{{ $id ?? 'card' }}-body"
                            aria-expanded="{{ $collapsed ? 'false' : 'true' }}"
                        >
                            <i class="fas fa-chevron-{{ $collapsed ? 'down' : 'up' }}"></i>
                        </button>
                    @endif
                </h5>
                @endif

                @if($subtitle)
                <p class="card-subtitle text-muted small mb-0 mt-1">{{ $subtitle }}</p>
                @endif
            </div>

            @if(isset($actions))
            <div class="card-actions">
                {{ $actions }}
            </div>
            @endif
        </div>
    </div>
    @endif

    <div
        class="card-body {{ $bodyClass }} {{ $collapsible ? 'collapse' : '' }} {{ !$collapsed ? 'show' : '' }}"
        @if($collapsible) id="{{ $id ?? 'card' }}-body" @endif
    >
        {{ $slot }}
    </div>

    @if(isset($footer))
    <div class="card-footer {{ $footerClass }}">
        {{ $footer }}
    </div>
    @endif
</div>

{{-- External CSS and JS for clean architecture --}}
@once
    @push('styles')
        <link href="{{ asset('css/components/card.css') }}" rel="stylesheet">
    @endpush
    @if($collapsible)
        @push('scripts')
            <script src="{{ asset('js/components/card.js') }}"></script>
        @endpush
    @endif
@endonce