{{--
    Admin User Menu Dropdown

    User profile dropdown with logout
--}}

<div class="nav-item dropdown">
    <a class="nav-link d-flex align-items-center" href="#" data-bs-toggle="dropdown">
        <div class="user-image me-2">
            <i class="fas fa-user"></i>
        </div>
        <span>{{ auth()->user()->FullName ?? 'User' }}</span>
        <i class="fas fa-chevron-down ms-2"></i>
    </a>
    <div class="dropdown-menu dropdown-menu-end">
        <h6 class="dropdown-header">{{ auth()->user()->USERID ?? 'USER' }}</h6>
        <div class="dropdown-divider"></div>
        <a class="dropdown-item" href="#">
            <i class="fas fa-user me-2"></i> Profile
        </a>
        <a class="dropdown-item" href="#">
            <i class="fas fa-cog me-2"></i> Settings
        </a>
        <div class="dropdown-divider"></div>
        <form action="{{ route('logout') }}" method="POST" class="d-inline">
            @csrf
            <button type="submit" class="dropdown-item">
                <i class="fas fa-sign-out-alt me-2"></i> Logout
            </button>
        </form>
    </div>
</div>