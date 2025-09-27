{{--
    Dashboard Quick Stats Component

    Displays user quick stats in a compact card format
    Props: $user (required)
--}}

@props(['user'])

<x-card title="Quick Stats" icon="fas fa-chart-bar">
    <div class="stats-list">
        <div class="stat-item d-flex justify-content-between">
            <span>Session:</span>
            <span class="badge bg-primary">Active</span>
        </div>
        <div class="stat-item d-flex justify-content-between">
            <span>User Level:</span>
            <span class="badge bg-info">{{ $user->getUserLevelName() }}</span>
        </div>
        <div class="stat-item d-flex justify-content-between">
            <span>Status:</span>
            <span class="badge bg-{{ $user->isActive() ? 'success' : 'danger' }}">
                {{ $user->isActive() ? 'Active' : 'Inactive' }}
            </span>
        </div>
        <div class="stat-item d-flex justify-content-between">
            <span>Admin Access:</span>
            <span class="badge bg-{{ $user->TINGKAT >= 4 ? 'success' : 'secondary' }}">
                {{ $user->TINGKAT >= 4 ? 'Yes' : 'No' }}
            </span>
        </div>
    </div>
</x-card>