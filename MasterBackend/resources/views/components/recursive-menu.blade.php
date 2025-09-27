{{-- Recursive Menu Component for unlimited nesting levels --}}
@if(count($items) > 0)
    @foreach($items as $item)
        <li class="nav-item {{ (isset($item['submenu']) && count($item['submenu']) > 0) || (isset($item['children']) && count($item['children']) > 0) ? 'has-treeview' : '' }}"
            data-menu-title="{{ strtolower($item['title']) }}">

            @if((isset($item['submenu']) && count($item['submenu']) > 0) || (isset($item['children']) && count($item['children']) > 0))
                {{-- Menu item with submenu --}}
                <a href="#" class="nav-link menu-toggle"
                   data-target="#menu-{{ Str::slug($item['title']) }}-{{ $loop->index }}"
                   style="padding-left: {{ ($level ?? 0) * 20 + 20 }}px;">
                    <i class="{{ $item['icon'] ?? 'far fa-circle' }}"></i>
                    <span class="menu-text">{{ $item['title'] }}</span>
                    <i class="fas fa-angle-left ms-auto menu-arrow"></i>
                </a>
                <ul class="nav nav-treeview collapse" id="menu-{{ Str::slug($item['title']) }}-{{ $loop->index }}">
                    {{-- Recursive call for submenu --}}
                    <x-recursive-menu :items="$item['submenu'] ?? $item['children']" :level="($level ?? 0) + 1" />
                </ul>
            @else
                {{-- Regular menu item --}}
                @php
                    $routeUrl = '#';
                    if (!empty($item['route'])) {
                        try {
                            // Check if it's a valid Laravel route name
                            if (\Route::has($item['route'])) {
                                $routeUrl = route($item['route']);
                            } elseif (str_starts_with($item['route'], '/')) {
                                // Direct URL starting with /
                                $routeUrl = $item['route'];
                            } else {
                                // Treat as relative URL, add leading slash
                                $routeUrl = '/' . ltrim($item['route'], '/');
                            }
                        } catch (\Exception $e) {
                            // If route resolution fails, use direct URL approach
                            $routeUrl = str_starts_with($item['route'], '/') ? $item['route'] : '/' . $item['route'];
                        }
                    }
                @endphp
                <a href="{{ $routeUrl }}" class="nav-link"
                   style="padding-left: {{ ($level ?? 0) * 20 + 20 }}px;">
                    <i class="{{ $item['icon'] ?? 'far fa-circle' }}"></i>
                    <span class="menu-text">{{ $item['title'] }}</span>
                </a>
            @endif
        </li>
    @endforeach
@endif