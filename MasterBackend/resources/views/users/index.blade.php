@extends('layouts.admin')

@section('title', 'User Management')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-0"><i class="fas fa-users"></i> User Management</h1>
        <p class="text-muted">Manage system users and their access</p>
    </div>
    <a href="{{ route('users.create') }}" class="btn btn-primary">
        <i class="fas fa-plus"></i> Add User
    </a>
</div>

<!-- Filters -->
<div class="card mb-4">
    <div class="card-body">
        <form method="GET" action="{{ route('users.index') }}" class="row g-3">
            <div class="col-md-4">
                <label for="search" class="form-label">Search</label>
                <input type="text" class="form-control" id="search" name="search" 
                       value="{{ request('search') }}" placeholder="User ID or Full Name">
            </div>
            <div class="col-md-2">
                <label for="status" class="form-label">Status</label>
                <select class="form-select" id="status" name="status">
                    <option value="">All Status</option>
                    <option value="1" {{ request('status') === '1' ? 'selected' : '' }}>Active</option>
                    <option value="0" {{ request('status') === '0' ? 'selected' : '' }}>Inactive</option>
                </select>
            </div>
            <div class="col-md-2">
                <label for="tingkat" class="form-label">User Level</label>
                <select class="form-select" id="tingkat" name="tingkat">
                    <option value="">All Levels</option>
                    <option value="5" {{ request('tingkat') === '5' ? 'selected' : '' }}>Super Admin (5)</option>
                    <option value="4" {{ request('tingkat') === '4' ? 'selected' : '' }}>Admin (4)</option>
                    <option value="3" {{ request('tingkat') === '3' ? 'selected' : '' }}>Manager (3)</option>
                    <option value="2" {{ request('tingkat') === '2' ? 'selected' : '' }}>Supervisor (2)</option>
                    <option value="1" {{ request('tingkat') === '1' ? 'selected' : '' }}>User (1)</option>
                </select>
            </div>
            <div class="col-md-4 d-flex align-items-end gap-2">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search"></i> Search
                </button>
                <a href="{{ route('users.index') }}" class="btn btn-outline-secondary">
                    <i class="fas fa-times"></i> Clear
                </a>
                <a href="{{ route('users.export', request()->query()) }}" class="btn btn-success">
                    <i class="fas fa-file-excel"></i> Export
                </a>
            </div>
        </form>
    </div>
</div>

<!-- Users Table -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
            <i class="fas fa-table"></i> Users List
            <span class="badge bg-primary">{{ $users->total() }} total</span>
        </h5>
        
        <!-- Bulk Actions -->
        <div class="dropdown">
            <button class="btn btn-outline-secondary btn-sm dropdown-toggle" type="button" 
                    data-bs-toggle="dropdown" id="bulkActions" disabled>
                <i class="fas fa-cogs"></i> Bulk Actions
            </button>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="#" onclick="bulkToggleStatus('activate')">
                    <i class="fas fa-check"></i> Activate Selected
                </a></li>
                <li><a class="dropdown-item" href="#" onclick="bulkToggleStatus('deactivate')">
                    <i class="fas fa-ban"></i> Deactivate Selected
                </a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="#" onclick="bulkDelete()">
                    <i class="fas fa-trash"></i> Delete Selected
                </a></li>
            </ul>
        </div>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover" id="usersTable">
                <thead>
                    <tr>
                        <th width="40">
                            <input type="checkbox" id="selectAll" class="form-check-input">
                        </th>
                        <th>User ID</th>
                        <th>Full Name</th>
                        <th>Level</th>
                        <th>Status</th>
                        <th>Department</th>
                        <th>Permissions</th>
                        <th>Last Activity</th>
                        <th width="150">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($users as $user)
                    <tr>
                        <td>
                            <input type="checkbox" class="form-check-input user-checkbox" 
                                   value="{{ $user->USERID }}">
                        </td>
                        <td>
                            <strong>{{ $user->USERID }}</strong>
                        </td>
                        <td>{{ $user->FullName }}</td>
                        <td>
                            @php
                                $levelClass = match($user->TINGKAT) {
                                    5 => 'danger',
                                    4 => 'warning',
                                    3 => 'info',
                                    2 => 'secondary',
                                    default => 'light'
                                };
                                $levelName = match($user->TINGKAT) {
                                    5 => 'Super Admin',
                                    4 => 'Admin',
                                    3 => 'Manager',
                                    2 => 'Supervisor',
                                    default => 'User'
                                };
                            @endphp
                            <span class="badge bg-{{ $levelClass }}">{{ $levelName }} ({{ $user->TINGKAT }})</span>
                        </td>
                        <td>
                            <div class="form-check form-switch">
                                <input class="form-check-input status-toggle" type="checkbox" 
                                       {{ $user->STATUS ? 'checked' : '' }}
                                       data-userid="{{ $user->USERID }}"
                                       onchange="toggleUserStatus('{{ $user->USERID }}', this.checked)">
                                <label class="form-check-label">
                                    {{ $user->STATUS ? 'Active' : 'Inactive' }}
                                </label>
                            </div>
                        </td>
                        <td>
                            @if($user->kodeBag)
                                <span class="badge bg-light text-dark">{{ $user->kodeBag }}</span>
                            @else
                                <span class="text-muted">-</span>
                            @endif
                        </td>
                        <td>
                            @if(isset($user->permission_summary))
                            <div class="d-flex gap-1">
                                <span class="badge bg-success" title="Accessible Menus">
                                    {{ $user->permission_summary['accessible_menus'] }}/{{ $user->permission_summary['total_menus'] }}
                                </span>
                                @if($user->permission_summary['add_permissions'] > 0)
                                    <span class="badge bg-primary" title="Add Permissions">+{{ $user->permission_summary['add_permissions'] }}</span>
                                @endif
                                @if($user->permission_summary['delete_permissions'] > 0)
                                    <span class="badge bg-danger" title="Delete Permissions">-{{ $user->permission_summary['delete_permissions'] }}</span>
                                @endif
                            </div>
                            @else
                                <span class="text-muted">No data</span>
                            @endif
                        </td>
                        <td>
                            @if($user->IPAddres)
                                <small class="text-muted">{{ $user->IPAddres }}</small>
                            @else
                                <span class="text-muted">Never</span>
                            @endif
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm" role="group">
                                <a href="{{ route('users.show', $user->USERID) }}" 
                                   class="btn btn-outline-info" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="{{ route('users.edit', $user->USERID) }}" 
                                   class="btn btn-outline-primary" title="Edit User">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="{{ route('permissions.matrix', $user->USERID) }}" 
                                   class="btn btn-outline-success" title="Manage Permissions">
                                    <i class="fas fa-key"></i>
                                </a>
                                @if(session('user.TINGKAT') >= 5 && $user->USERID !== session('user.USERID'))
                                <button type="button" class="btn btn-outline-danger" 
                                        title="Delete User"
                                        onclick="deleteUser('{{ $user->USERID }}')">
                                    <i class="fas fa-trash"></i>
                                </button>
                                @endif
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="9" class="text-center py-4 text-muted">
                            <i class="fas fa-users fa-2x mb-2"></i><br>
                            No users found
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        @if($users->hasPages())
        <div class="d-flex justify-content-between align-items-center mt-3">
            <div class="text-muted">
                Showing {{ $users->firstItem() }} to {{ $users->lastItem() }} of {{ $users->total() }} users
            </div>
            {{ $users->links() }}
        </div>
        @endif
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {
    // Select All functionality
    $('#selectAll').change(function() {
        const isChecked = $(this).is(':checked');
        $('.user-checkbox').prop('checked', isChecked);
        toggleBulkActions();
    });

    // Individual checkbox change
    $('.user-checkbox').change(function() {
        const totalCheckboxes = $('.user-checkbox').length;
        const checkedCheckboxes = $('.user-checkbox:checked').length;
        
        $('#selectAll').prop('checked', totalCheckboxes === checkedCheckboxes);
        toggleBulkActions();
    });

    function toggleBulkActions() {
        const selectedCount = $('.user-checkbox:checked').length;
        $('#bulkActions').prop('disabled', selectedCount === 0);
    }
});

// Toggle user status
function toggleUserStatus(userId, isActive) {
    $.ajax({
        url: `/users/${userId}/toggle-status`,
        method: 'POST',
        success: function(response) {
            if (response.success) {
                showAlert('success', response.message);
                // Update status label
                const checkbox = $(`input[data-userid="${userId}"]`);
                const label = checkbox.next('label');
                label.text(isActive ? 'Active' : 'Inactive');
            } else {
                showAlert('error', response.message);
                // Revert checkbox
                $(`input[data-userid="${userId}"]`).prop('checked', !isActive);
            }
        },
        error: function() {
            showAlert('error', 'Failed to update user status');
            // Revert checkbox
            $(`input[data-userid="${userId}"]`).prop('checked', !isActive);
        }
    });
}

// Delete user
function deleteUser(userId) {
    confirmAction(`This will permanently delete user "${userId}" and all their permissions.`, function() {
        $.ajax({
            url: `/users/${userId}`,
            method: 'DELETE',
            success: function(response) {
                if (response.success || response.message) {
                    showAlert('success', response.message || 'User deleted successfully');
                    location.reload();
                } else {
                    showAlert('error', 'Failed to delete user');
                }
            },
            error: function(xhr) {
                const response = xhr.responseJSON;
                showAlert('error', response?.message || 'Failed to delete user');
            }
        });
    });
}

// Bulk actions
function bulkToggleStatus(action) {
    const selectedUsers = $('.user-checkbox:checked').map(function() {
        return $(this).val();
    }).get();

    if (selectedUsers.length === 0) {
        showAlert('warning', 'Please select users first');
        return;
    }

    const actionText = action === 'activate' ? 'activate' : 'deactivate';
    confirmAction(`This will ${actionText} ${selectedUsers.length} selected users.`, function() {
        // Implementation for bulk status toggle
        showAlert('info', 'Bulk actions feature coming soon');
    });
}

function bulkDelete() {
    const selectedUsers = $('.user-checkbox:checked').map(function() {
        return $(this).val();
    }).get();

    if (selectedUsers.length === 0) {
        showAlert('warning', 'Please select users first');
        return;
    }

    confirmAction(`This will permanently delete ${selectedUsers.length} selected users and all their permissions.`, function() {
        // Implementation for bulk delete
        showAlert('info', 'Bulk delete feature coming soon');
    });
}
</script>
@endpush