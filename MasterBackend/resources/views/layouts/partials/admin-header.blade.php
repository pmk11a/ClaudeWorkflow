{{--
    Admin Header Navigation

    Top navigation bar with brand, notifications, and user menu
--}}

<nav class="main-header navbar navbar-expand-lg navbar-light">
    <div class="container-fluid">
        <!-- Brand -->
        <a class="navbar-brand d-flex align-items-center" href="{{ route('dashboard') }}">
            <i class="fas fa-building me-2 text-primary"></i>
            <strong>DAPEN-KA</strong>
        </a>

        <!-- Sidebar Toggle -->
        <button type="button" class="btn btn-link sidebar-toggle d-lg-none">
            <i class="fas fa-bars"></i>
        </button>

        <!-- Right Side Menu -->
        <div class="navbar-nav ms-auto">
            @include('layouts.partials.admin-notifications')
            @include('layouts.partials.admin-user-menu')
        </div>
    </div>
</nav>