{{--
    Admin Sidebar Navigation Menu

    Main navigation menu with dynamic and static items
--}}

<!-- Navigation Menu -->
<nav class="mt-2 sidebar-nav">
    <ul class="nav nav-sidebar flex-column" id="sidebarMenu">
        <!-- Dashboard -->
        <li class="nav-item">
            <a href="{{ route('dashboard') }}" class="nav-link {{ request()->routeIs('dashboard') ? 'active' : '' }}">
                <i class="fas fa-tachometer-alt"></i>
                Dashboard
            </a>
        </li>

        <!-- Dynamic Menu Items with Unlimited Hierarchy -->
        @if(isset($userMenus))
            @foreach($userMenus as $menuGroup)
            <li class="nav-item has-treeview" data-menu-title="{{ strtolower($menuGroup['title']) }}">
                <a href="#" class="nav-link menu-toggle" data-target="#menu-{{ Str::slug($menuGroup['title']) }}">
                    <i class="{{ $menuGroup['icon'] ?? 'fas fa-folder' }}"></i>
                    <span class="menu-text">{{ $menuGroup['title'] }}</span>
                    <i class="fas fa-angle-left ms-auto menu-arrow"></i>
                </a>
                <ul class="nav nav-treeview collapse" id="menu-{{ Str::slug($menuGroup['title']) }}">
                    {{-- Use recursive menu component for unlimited nesting --}}
                    <x-recursive-menu :items="$menuGroup['items']" :level="1" />
                </ul>
            </li>
            @endforeach
        @endif

        <!-- Admin Tools Section -->
        @if(auth()->user() && auth()->user()->TINGKAT >= 3)
        <li class="nav-item nav-separator">
            <hr class="bg-secondary opacity-25 my-2">
            <small class="text-muted px-3">Admin Tools</small>
        </li>

        <!-- User Management -->
        <li class="nav-item">
            <a href="{{ route('users.index') }}" class="nav-link {{ request()->routeIs('users.*') ? 'active' : '' }}">
                <i class="fas fa-users"></i>
                User Management
            </a>
        </li>
        @endif

        <!-- Permission Management -->
        @if(auth()->user() && auth()->user()->TINGKAT >= 4)
        <li class="nav-item">
            <a href="{{ route('permissions.bulk') }}" class="nav-link {{ request()->routeIs('permissions.*') ? 'active' : '' }}">
                <i class="fas fa-key"></i>
                Permissions
            </a>
        </li>

        <!-- Menu Management -->
        <li class="nav-item">
            <a href="#" class="nav-link">
                <i class="fas fa-sitemap"></i>
                Menu Management
            </a>
        </li>

        <!-- System Diagnostics -->
        <li class="nav-item">
            <a href="{{ route('diagnostics.index') }}" class="nav-link {{ request()->routeIs('diagnostics.*') ? 'active' : '' }}">
                <i class="fas fa-tools"></i>
                System Diagnostics
            </a>
        </li>
        @endif
    </ul>
</nav>