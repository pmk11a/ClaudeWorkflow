{{--
    Admin Sidebar Header

    User panel and period selector
--}}

<!-- Sidebar Header -->
<div class="sidebar-header">
    <div class="user-panel">
        <div class="user-image">
            <i class="fas fa-user-tie"></i>
        </div>
        <div class="user-info">
            <h6>{{ auth()->user()->FullName ?? 'User' }}</h6>
            <small>{{ auth()->user()->getUserLevelName() ?? 'Level N/A' }}</small>
        </div>
    </div>
</div>

<!-- Period Selector -->
<div class="period-selector-container">
    <div class="period-display">
        <i class="fas fa-calendar-alt me-2"></i>
        <span class="period-text">Periode : {{ date('m') }} Bulan {{ date('Y') }} Tahun</span>
    </div>
    <button type="button" class="btn btn-sm btn-outline-light period-change-btn" data-bs-toggle="modal" data-bs-target="#periodModal">
        <i class="fas fa-edit"></i>
    </button>
</div>