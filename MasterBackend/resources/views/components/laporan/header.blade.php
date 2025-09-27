{{-- Laporan Dashboard Header Component --}}
<div class="header">
    <div class="header-left">
        <button class="menu-toggle" onclick="toggleSidebar()">
            ☰
        </button>
        <div class="header-title">
            <span>🏢</span>
            <a href="{{ route('dashboard') }}" style="color: white; text-decoration: none; transition: opacity 0.3s ease;"
               onmouseover="this.style.opacity='0.8'" onmouseout="this.style.opacity='1'"
               title="Back to Dashboard">
                <span>DAPEN ERP</span>
            </a>
        </div>
    </div>
    <div class="header-right">
        <div class="user-info">
            <span>👤</span>
            <span>{{ $user->name }}</span>
        </div>
        <a href="#" class="logout-btn">🚪 Logout</a>
    </div>
</div>