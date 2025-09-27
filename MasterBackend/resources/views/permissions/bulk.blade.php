@extends('layouts.admin')

@section('title', 'Bulk Permission Management')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-0"><i class="fas fa-users-cog"></i> Bulk Permission Management</h1>
        <p class="text-muted">Manage permissions for multiple users at once</p>
    </div>
    <a href="{{ route('users.index') }}" class="btn btn-outline-secondary">
        <i class="fas fa-arrow-left"></i> Back to Users
    </a>
</div>

<!-- User Selection Card -->
<div class="card mb-4">
    <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-user-check"></i> Select Users</h5>
    </div>
    <div class="card-body">
        <div class="row mb-3">
            <div class="col-md-8">
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-search"></i></span>
                    <input type="text" class="form-control" id="userSearch" 
                           placeholder="Search users by ID or name...">
                </div>
            </div>
            <div class="col-md-4">
                <select class="form-select" id="levelFilter">
                    <option value="">All Levels</option>
                    <option value="5">Super Admin (5)</option>
                    <option value="4">Admin (4)</option>
                    <option value="3">Manager (3)</option>
                    <option value="2">Supervisor (2)</option>
                    <option value="1">User (1)</option>
                </select>
            </div>
        </div>
        
        <div class="table-responsive" style="max-height: 300px;">
            <table class="table table-sm table-hover" id="usersTable">
                <thead class="table-light sticky-top">
                    <tr>
                        <th width="40">
                            <input type="checkbox" id="selectAllUsers" class="form-check-input">
                        </th>
                        <th>User ID</th>
                        <th>Full Name</th>
                        <th>Level</th>
                        <th>Status</th>
                        <th>Permissions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($users as $user)
                    <tr data-userid="{{ $user->USERID }}" data-level="{{ $user->TINGKAT }}">
                        <td>
                            <input type="checkbox" class="form-check-input user-checkbox" 
                                   value="{{ $user->USERID }}">
                        </td>
                        <td><strong>{{ $user->USERID }}</strong></td>
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
                            <span class="badge bg-{{ $user->STATUS ? 'success' : 'danger' }}">
                                {{ $user->STATUS ? 'Active' : 'Inactive' }}
                            </span>
                        </td>
                        <td>
                            <a href="{{ route('permissions.matrix', $user->USERID) }}" 
                               class="btn btn-outline-primary btn-sm" title="Manage Permissions">
                                <i class="fas fa-key"></i>
                            </a>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="text-center text-muted">No users found</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        
        <div class="mt-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <span id="selectedCount" class="text-muted">0 users selected</span>
                </div>
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-outline-primary" onclick="selectActiveUsers()">
                        Select Active Users
                    </button>
                    <button type="button" class="btn btn-outline-secondary" onclick="selectByLevel()">
                        Select by Level
                    </button>
                    <button type="button" class="btn btn-outline-warning" onclick="clearSelection()">
                        Clear Selection
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Permission Actions Card -->
<div class="card mb-4">
    <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-cogs"></i> Bulk Actions</h5>
    </div>
    <div class="card-body">
        <div class="row g-3">
            <!-- Copy from User Action -->
            <div class="col-lg-4">
                <div class="card h-100 border-primary">
                    <div class="card-body text-center">
                        <i class="fas fa-copy fa-2x text-primary mb-3"></i>
                        <h6 class="card-title">Copy from User</h6>
                        <p class="card-text small text-muted">
                            Copy all permissions from an existing user to selected users
                        </p>
                        <select class="form-select form-select-sm mb-2" id="sourceUserForCopy">
                            <option value="">Select source user...</option>
                            @foreach($users as $user)
                                <option value="{{ $user->USERID }}">{{ $user->USERID }} - {{ $user->FullName }}</option>
                            @endforeach
                        </select>
                        <button type="button" class="btn btn-outline-primary btn-sm" 
                                onclick="executeBulkAction('copy_from_user')" disabled id="copyFromUserBtn">
                            <i class="fas fa-copy"></i> Apply
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Set by Level Action -->
            <div class="col-lg-4">
                <div class="card h-100 border-success">
                    <div class="card-body text-center">
                        <i class="fas fa-layer-group fa-2x text-success mb-3"></i>
                        <h6 class="card-title">Set by User Level</h6>
                        <p class="card-text small text-muted">
                            Set default permissions based on user access level
                        </p>
                        <select class="form-select form-select-sm mb-2" id="targetLevel">
                            <option value="">Select target level...</option>
                            <option value="5">Super Admin (5) - Full Access</option>
                            <option value="4">Admin (4) - Most Access</option>
                            <option value="3">Manager (3) - Management Access</option>
                            <option value="2">Supervisor (2) - Limited Access</option>
                            <option value="1">User (1) - Basic Access</option>
                        </select>
                        <button type="button" class="btn btn-outline-success btn-sm" 
                                onclick="executeBulkAction('set_by_level')" disabled id="setByLevelBtn">
                            <i class="fas fa-layer-group"></i> Apply
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Custom Permissions Action -->
            <div class="col-lg-4">
                <div class="card h-100 border-warning">
                    <div class="card-body text-center">
                        <i class="fas fa-sliders-h fa-2x text-warning mb-3"></i>
                        <h6 class="card-title">Custom Permissions</h6>
                        <p class="card-text small text-muted">
                            Apply custom permission template to selected users
                        </p>
                        <button type="button" class="btn btn-outline-warning btn-sm" 
                                onclick="showCustomPermissionModal()" disabled id="customPermBtn">
                            <i class="fas fa-sliders-h"></i> Configure
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <hr class="my-4">
        <div class="row">
            <div class="col-md-6">
                <h6><i class="fas fa-bolt"></i> Quick Actions</h6>
                <div class="btn-group btn-group-sm" role="group">
                    <button type="button" class="btn btn-outline-success" 
                            onclick="bulkToggleStatus(true)" disabled id="activateBtn">
                        <i class="fas fa-check"></i> Activate Selected
                    </button>
                    <button type="button" class="btn btn-outline-secondary" 
                            onclick="bulkToggleStatus(false)" disabled id="deactivateBtn">
                        <i class="fas fa-ban"></i> Deactivate Selected
                    </button>
                </div>
            </div>
            <div class="col-md-6 text-end">
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-outline-info" onclick="compareUsers()" 
                            disabled id="compareBtn">
                        <i class="fas fa-balance-scale"></i> Compare Permissions
                    </button>
                    <button type="button" class="btn btn-outline-secondary" onclick="exportSelected()" 
                            disabled id="exportBtn">
                        <i class="fas fa-download"></i> Export Selected
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Recent Bulk Operations -->
<div class="card">
    <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-history"></i> Recent Operations</h5>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-sm">
                <thead class="table-light">
                    <tr>
                        <th>Date</th>
                        <th>Action</th>
                        <th>Users Affected</th>
                        <th>Performed By</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-3">
                            <i class="fas fa-clock"></i> Operation history will appear here
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Custom Permission Modal -->
<div class="modal fade" id="customPermissionModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-sliders-h"></i> Custom Permission Template</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Configure permissions to apply to all selected users:</p>
                
                <!-- Menu Selection for Custom Permissions -->
                <div class="row g-3">
                    @foreach($allMenus->groupBy('L0') as $level => $menus)
                    <div class="col-md-6">
                        <div class="card border-light">
                            <div class="card-header bg-light py-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <strong>{{ $level ?: 'Other' }}</strong>
                                    <div class="btn-group btn-group-sm">
                                        <button type="button" class="btn btn-outline-success btn-sm" 
                                                onclick="selectAllInGroup('{{ $level }}')">All</button>
                                        <button type="button" class="btn btn-outline-warning btn-sm" 
                                                onclick="clearAllInGroup('{{ $level }}')">None</button>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body p-2">
                                @foreach($menus as $menu)
                                <div class="form-check form-check-sm">
                                    <input class="form-check-input custom-menu-check" type="checkbox" 
                                           value="{{ $menu->KODEMENU }}" id="menu-{{ $menu->KODEMENU }}"
                                           data-group="{{ $level }}">
                                    <label class="form-check-label small" for="menu-{{ $menu->KODEMENU }}">
                                        {{ $menu->KODEMENU }} - {{ $menu->Keterangan }}
                                    </label>
                                </div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    @endforeach
                </div>
                
                <!-- Permission Types -->
                <hr>
                <h6>Permission Types:</h6>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="customHasAccess" checked>
                            <label class="form-check-label" for="customHasAccess">
                                <i class="fas fa-eye text-success"></i> Access
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="customAdd">
                            <label class="form-check-label" for="customAdd">
                                <i class="fas fa-plus text-primary"></i> Add/Create
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="customEdit">
                            <label class="form-check-label" for="customEdit">
                                <i class="fas fa-edit text-info"></i> Edit/Update
                            </label>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="customDelete">
                            <label class="form-check-label" for="customDelete">
                                <i class="fas fa-trash text-danger"></i> Delete
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="customPrint">
                            <label class="form-check-label" for="customPrint">
                                <i class="fas fa-print text-secondary"></i> Print
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="customExport">
                            <label class="form-check-label" for="customExport">
                                <i class="fas fa-download text-warning"></i> Export
                            </label>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-warning" onclick="executeCustomPermissions()">
                    <i class="fas fa-sliders-h"></i> Apply Custom Permissions
                </button>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {
    // Initialize event handlers
    initializeEventHandlers();
    updateButtonStates();
});

function initializeEventHandlers() {
    // Select all checkbox
    $('#selectAllUsers').change(function() {
        const isChecked = $(this).is(':checked');
        $('.user-checkbox:visible').prop('checked', isChecked);
        updateSelectedCount();
        updateButtonStates();
    });

    // Individual user checkboxes
    $('.user-checkbox').change(function() {
        updateSelectedCount();
        updateButtonStates();
        
        const totalVisible = $('.user-checkbox:visible').length;
        const checkedVisible = $('.user-checkbox:visible:checked').length;
        $('#selectAllUsers').prop('checked', totalVisible > 0 && totalVisible === checkedVisible);
    });

    // Search functionality
    $('#userSearch').on('input', function() {
        filterUsers();
    });

    // Level filter
    $('#levelFilter').change(function() {
        filterUsers();
    });

    // Source user selection for copy
    $('#sourceUserForCopy').change(function() {
        updateButtonStates();
    });

    // Target level selection
    $('#targetLevel').change(function() {
        updateButtonStates();
    });
}

function filterUsers() {
    const searchTerm = $('#userSearch').val().toLowerCase();
    const levelFilter = $('#levelFilter').val();

    $('#usersTable tbody tr').each(function() {
        const $row = $(this);
        const userid = $row.find('td:nth-child(2)').text().toLowerCase();
        const fullname = $row.find('td:nth-child(3)').text().toLowerCase();
        const userLevel = $row.data('level');

        const matchesSearch = !searchTerm || userid.includes(searchTerm) || fullname.includes(searchTerm);
        const matchesLevel = !levelFilter || userLevel == levelFilter;

        if (matchesSearch && matchesLevel) {
            $row.show();
        } else {
            $row.hide();
            $row.find('.user-checkbox').prop('checked', false);
        }
    });

    updateSelectedCount();
    updateButtonStates();
}

function updateSelectedCount() {
    const count = $('.user-checkbox:checked').length;
    $('#selectedCount').text(`${count} users selected`);
}

function updateButtonStates() {
    const selectedCount = $('.user-checkbox:checked').length;
    const hasSource = $('#sourceUserForCopy').val() !== '';
    const hasLevel = $('#targetLevel').val() !== '';

    // Enable/disable buttons based on selection
    $('#copyFromUserBtn').prop('disabled', selectedCount === 0 || !hasSource);
    $('#setByLevelBtn').prop('disabled', selectedCount === 0 || !hasLevel);
    $('#customPermBtn').prop('disabled', selectedCount === 0);
    $('#activateBtn').prop('disabled', selectedCount === 0);
    $('#deactivateBtn').prop('disabled', selectedCount === 0);
    $('#compareBtn').prop('disabled', selectedCount < 2);
    $('#exportBtn').prop('disabled', selectedCount === 0);
}

function selectActiveUsers() {
    $('.user-checkbox').each(function() {
        const $row = $(this).closest('tr');
        const isActive = $row.find('.badge:contains("Active")').length > 0;
        $(this).prop('checked', isActive);
    });
    updateSelectedCount();
    updateButtonStates();
}

function selectByLevel() {
    const level = prompt('Enter user level to select (1-5):');
    if (level && level >= 1 && level <= 5) {
        $('.user-checkbox').each(function() {
            const $row = $(this).closest('tr');
            const userLevel = $row.data('level');
            $(this).prop('checked', userLevel == level);
        });
        updateSelectedCount();
        updateButtonStates();
    }
}

function clearSelection() {
    $('.user-checkbox').prop('checked', false);
    $('#selectAllUsers').prop('checked', false);
    updateSelectedCount();
    updateButtonStates();
}

function executeBulkAction(action) {
    const selectedUsers = getSelectedUsers();
    if (selectedUsers.length === 0) {
        showAlert('warning', 'Please select users first');
        return;
    }

    let actionData = {
        user_ids: selectedUsers,
        permission_action: action
    };

    let confirmMessage = `Apply ${action.replace('_', ' ')} to ${selectedUsers.length} selected users?`;

    if (action === 'copy_from_user') {
        const sourceUser = $('#sourceUserForCopy').val();
        if (!sourceUser) {
            showAlert('warning', 'Please select a source user');
            return;
        }
        actionData.source_user = sourceUser;
        confirmMessage = `Copy permissions from ${sourceUser} to ${selectedUsers.length} selected users?`;
    } else if (action === 'set_by_level') {
        const userLevel = $('#targetLevel').val();
        if (!userLevel) {
            showAlert('warning', 'Please select a target level');
            return;
        }
        actionData.user_level = parseInt(userLevel);
        confirmMessage = `Set level ${userLevel} permissions for ${selectedUsers.length} selected users?`;
    }

    confirmAction(confirmMessage, function() {
        performBulkAction(actionData);
    });
}

function performBulkAction(actionData) {
    $.ajax({
        url: '/permissions/bulk-apply',
        method: 'POST',
        data: actionData,
        success: function(response) {
            if (response.success) {
                showAlert('success', response.message);
                // Optionally reload or update the interface
            } else {
                showAlert('error', response.message);
            }
        },
        error: function(xhr) {
            const response = xhr.responseJSON;
            showAlert('error', response?.message || 'Failed to perform bulk action');
        }
    });
}

function getSelectedUsers() {
    return $('.user-checkbox:checked').map(function() {
        return $(this).val();
    }).get();
}

function showCustomPermissionModal() {
    $('#customPermissionModal').modal('show');
}

function selectAllInGroup(group) {
    $(`.custom-menu-check[data-group="${group}"]`).prop('checked', true);
}

function clearAllInGroup(group) {
    $(`.custom-menu-check[data-group="${group}"]`).prop('checked', false);
}

function executeCustomPermissions() {
    const selectedMenus = $('.custom-menu-check:checked').map(function() {
        return $(this).val();
    }).get();

    if (selectedMenus.length === 0) {
        showAlert('warning', 'Please select at least one menu');
        return;
    }

    const permissions = {
        has_access: $('#customHasAccess').is(':checked'),
        add: $('#customAdd').is(':checked'),
        edit: $('#customEdit').is(':checked'),
        delete: $('#customDelete').is(':checked'),
        print: $('#customPrint').is(':checked'),
        export: $('#customExport').is(':checked')
    };

    const customPermissions = {};
    selectedMenus.forEach(menu => {
        customPermissions[menu] = permissions;
    });

    const actionData = {
        user_ids: getSelectedUsers(),
        permission_action: 'custom_permissions',
        custom_permissions: customPermissions
    };

    performBulkAction(actionData);
    $('#customPermissionModal').modal('hide');
}

function bulkToggleStatus(activate) {
    const selectedUsers = getSelectedUsers();
    const action = activate ? 'activate' : 'deactivate';
    
    confirmAction(`This will ${action} ${selectedUsers.length} selected users.`, function() {
        showAlert('info', 'Bulk status change feature coming soon');
    });
}

function compareUsers() {
    const selectedUsers = getSelectedUsers();
    if (selectedUsers.length < 2) {
        showAlert('warning', 'Please select at least 2 users to compare');
        return;
    }
    
    showAlert('info', 'Permission comparison feature coming soon');
}

function exportSelected() {
    const selectedUsers = getSelectedUsers();
    const userParams = selectedUsers.map(user => `users[]=${user}`).join('&');
    window.location.href = `/permissions/export?${userParams}`;
}
</script>
@endpush

@push('styles')
<style>
.table tbody tr:hover {
    background-color: rgba(0,123,255,0.1);
}

.user-checkbox {
    transform: scale(1.1);
}

.sticky-top {
    position: sticky;
    top: 0;
    z-index: 10;
}

.form-check-sm .form-check-input {
    transform: scale(0.9);
}

.form-check-sm .form-check-label {
    font-size: 0.85rem;
}
</style>
@endpush