@extends('layouts.admin')

@section('title', 'Permission Matrix - ' . $user->USERID)

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-0"><i class="fas fa-key"></i> Permission Matrix</h1>
        <p class="text-muted">
            Manage permissions for: <strong>{{ $user->FullName }}</strong> ({{ $user->USERID }})
            <span class="badge bg-{{ $user->STATUS ? 'success' : 'danger' }} ms-2">
                {{ $user->STATUS ? 'Active' : 'Inactive' }}
            </span>
        </p>
    </div>
    <div class="btn-group">
        <a href="{{ route('users.show', $user->USERID) }}" class="btn btn-outline-info">
            <i class="fas fa-user"></i> View User
        </a>
        <a href="{{ route('users.edit', $user->USERID) }}" class="btn btn-outline-primary">
            <i class="fas fa-edit"></i> Edit User
        </a>
        <a href="{{ route('users.index') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> Back to Users
        </a>
    </div>
</div>

<!-- Permission Summary Card -->
<div class="card mb-4">
    <div class="card-body">
        <div class="row g-3 text-center">
            @if(isset($permissionSummary))
            <div class="col-md-2">
                <div class="border rounded p-2">
                    <h5 class="mb-0 text-primary">{{ $permissionSummary['total_menus'] }}</h5>
                    <small class="text-muted">Total Menus</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="border rounded p-2">
                    <h5 class="mb-0 text-success">{{ $permissionSummary['accessible_menus'] }}</h5>
                    <small class="text-muted">Accessible</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="border rounded p-2">
                    <h5 class="mb-0 text-info">{{ $permissionSummary['add_permissions'] }}</h5>
                    <small class="text-muted">Add Rights</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="border rounded p-2">
                    <h5 class="mb-0 text-warning">{{ $permissionSummary['edit_permissions'] }}</h5>
                    <small class="text-muted">Edit Rights</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="border rounded p-2">
                    <h5 class="mb-0 text-danger">{{ $permissionSummary['delete_permissions'] }}</h5>
                    <small class="text-muted">Delete Rights</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="border rounded p-2">
                    <h5 class="mb-0 text-secondary">{{ $permissionSummary['export_permissions'] }}</h5>
                    <small class="text-muted">Export Rights</small>
                </div>
            </div>
            @endif
        </div>
    </div>
</div>

<!-- Action Buttons -->
<div class="card mb-4">
    <div class="card-body">
        <div class="row g-2">
            <div class="col-md-8">
                <div class="btn-group me-2" role="group">
                    <button type="button" class="btn btn-outline-success btn-sm" onclick="selectAllAccess()">
                        <i class="fas fa-check-square"></i> Select All Access
                    </button>
                    <button type="button" class="btn btn-outline-warning btn-sm" onclick="clearAllPermissions()">
                        <i class="fas fa-square"></i> Clear All
                    </button>
                </div>
                <div class="btn-group me-2" role="group">
                    <button type="button" class="btn btn-outline-info btn-sm" onclick="resetToDefault()">
                        <i class="fas fa-refresh"></i> Reset to Default
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm" onclick="copyFromUser()">
                        <i class="fas fa-copy"></i> Copy from User
                    </button>
                </div>
                <button type="button" class="btn btn-primary btn-sm" onclick="saveAllChanges()">
                    <i class="fas fa-save"></i> Save All Changes
                </button>
            </div>
            <div class="col-md-4 text-end">
                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="expandAll()">
                    <i class="fas fa-expand"></i> Expand All
                </button>
                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="collapseAll()">
                    <i class="fas fa-compress"></i> Collapse All
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Permission Matrix -->
<div class="card">
    <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-table"></i> Permission Matrix</h5>
    </div>
    <div class="card-body p-0">
        @if(isset($permissionHierarchy) && count($permissionHierarchy) > 0)
        <div class="table-responsive permission-matrix">
            <table class="table table-hover mb-0" id="permissionMatrix">
                <thead class="table-dark sticky-top">
                    <tr>
                        <th width="300">Menu</th>
                        <th width="80" class="text-center">
                            <i class="fas fa-eye" title="Access"></i><br>
                            <small>Access</small>
                        </th>
                        <th width="80" class="text-center">
                            <i class="fas fa-plus" title="Add"></i><br>
                            <small>Add</small>
                        </th>
                        <th width="80" class="text-center">
                            <i class="fas fa-edit" title="Edit"></i><br>
                            <small>Edit</small>
                        </th>
                        <th width="80" class="text-center">
                            <i class="fas fa-trash" title="Delete"></i><br>
                            <small>Delete</small>
                        </th>
                        <th width="80" class="text-center">
                            <i class="fas fa-print" title="Print"></i><br>
                            <small>Print</small>
                        </th>
                        <th width="80" class="text-center">
                            <i class="fas fa-download" title="Export"></i><br>
                            <small>Export</small>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($permissionHierarchy as $level => $levelData)
                    <!-- Level Header -->
                    <tr class="menu-level table-secondary">
                        <td colspan="7">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <i class="fas fa-folder me-2"></i>
                                    <strong>{{ $level }}</strong>
                                    <span class="badge bg-primary ms-2">{{ count($levelData['menus']) }} menus</span>
                                </div>
                                <div class="btn-group btn-group-sm">
                                    <button class="btn btn-outline-dark btn-sm" onclick="toggleLevel('{{ $level }}')" 
                                            id="toggle-{{ Str::slug($level) }}">
                                        <i class="fas fa-chevron-down"></i>
                                    </button>
                                    <button class="btn btn-outline-success btn-sm" onclick="selectLevelAccess('{{ $level }}')">
                                        <i class="fas fa-check"></i> All Access
                                    </button>
                                    <button class="btn btn-outline-warning btn-sm" onclick="clearLevel('{{ $level }}')">
                                        <i class="fas fa-times"></i> Clear
                                    </button>
                                </div>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Menu Items -->
                    @foreach($levelData['menus'] as $menu)
                    <tr class="menu-item level-{{ Str::slug($level) }}" data-menu="{{ $menu['code'] }}">
                        <td>
                            <div class="ps-3">
                                <strong>{{ $menu['code'] }}</strong><br>
                                <small class="text-muted">{{ $menu['caption'] }}</small>
                                @if($menu['access'])
                                    <span class="badge bg-success ms-2">System Enabled</span>
                                @endif
                            </div>
                        </td>
                        <td class="text-center">
                            <input type="checkbox" class="form-check-input permission-checkbox access-checkbox" 
                                   data-menu="{{ $menu['code'] }}" data-permission="has_access"
                                   {{ $menu['permissions']['has_access'] ? 'checked' : '' }}
                                   onchange="updatePermission('{{ $menu['code'] }}', 'has_access', this.checked)">
                        </td>
                        <td class="text-center">
                            <input type="checkbox" class="form-check-input permission-checkbox add-checkbox" 
                                   data-menu="{{ $menu['code'] }}" data-permission="add"
                                   {{ $menu['permissions']['add'] ? 'checked' : '' }}
                                   onchange="updatePermission('{{ $menu['code'] }}', 'add', this.checked)">
                        </td>
                        <td class="text-center">
                            <input type="checkbox" class="form-check-input permission-checkbox edit-checkbox" 
                                   data-menu="{{ $menu['code'] }}" data-permission="edit"
                                   {{ $menu['permissions']['edit'] ? 'checked' : '' }}
                                   onchange="updatePermission('{{ $menu['code'] }}', 'edit', this.checked)">
                        </td>
                        <td class="text-center">
                            <input type="checkbox" class="form-check-input permission-checkbox delete-checkbox" 
                                   data-menu="{{ $menu['code'] }}" data-permission="delete"
                                   {{ $menu['permissions']['delete'] ? 'checked' : '' }}
                                   onchange="updatePermission('{{ $menu['code'] }}', 'delete', this.checked)">
                        </td>
                        <td class="text-center">
                            <input type="checkbox" class="form-check-input permission-checkbox print-checkbox" 
                                   data-menu="{{ $menu['code'] }}" data-permission="print"
                                   {{ $menu['permissions']['print'] ? 'checked' : '' }}
                                   onchange="updatePermission('{{ $menu['code'] }}', 'print', this.checked)">
                        </td>
                        <td class="text-center">
                            <input type="checkbox" class="form-check-input permission-checkbox export-checkbox" 
                                   data-menu="{{ $menu['code'] }}" data-permission="export"
                                   {{ $menu['permissions']['export'] ? 'checked' : '' }}
                                   onchange="updatePermission('{{ $menu['code'] }}', 'export', this.checked)">
                        </td>
                    </tr>
                    @endforeach
                    @endforeach
                </tbody>
            </table>
        </div>
        @else
        <div class="text-center py-5 text-muted">
            <i class="fas fa-key fa-3x mb-3"></i>
            <h5>No Menu Data Available</h5>
            <p>No menus found in the system to assign permissions.</p>
        </div>
        @endif
    </div>
</div>

<!-- Copy from User Modal -->
<div class="modal fade" id="copyFromUserModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-copy"></i> Copy Permissions from User</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Select a user to copy permissions from:</p>
                <div class="mb-3">
                    <select class="form-select" id="sourceUserSelect">
                        <option value="">Select user...</option>
                    </select>
                </div>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    This will replace ALL current permissions for {{ $user->USERID }}.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="executeCopyFromUser()">
                    <i class="fas fa-copy"></i> Copy Permissions
                </button>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
let pendingChanges = {};

$(document).ready(function() {
    loadUsersForCopy();
});

function updatePermission(menuCode, permission, isChecked) {
    // Handle access dependency
    if (permission !== 'has_access' && isChecked) {
        // Auto-check access if other permission is checked
        const accessCheckbox = $(`.permission-checkbox[data-menu="${menuCode}"][data-permission="has_access"]`);
        if (!accessCheckbox.prop('checked')) {
            accessCheckbox.prop('checked', true);
            updatePermission(menuCode, 'has_access', true);
        }
    } else if (permission === 'has_access' && !isChecked) {
        // Auto-uncheck other permissions if access is unchecked
        $(`.permission-checkbox[data-menu="${menuCode}"]`).not(`[data-permission="has_access"]`).prop('checked', false);
        ['add', 'edit', 'delete', 'print', 'export'].forEach(perm => {
            updatePermission(menuCode, perm, false);
        });
    }
    
    // Store pending change
    if (!pendingChanges[menuCode]) {
        pendingChanges[menuCode] = {};
    }
    pendingChanges[menuCode][permission] = isChecked;
    
    // Visual feedback
    const row = $(`.menu-item[data-menu="${menuCode}"]`);
    if (!row.hasClass('table-warning')) {
        row.addClass('table-warning');
    }
    
    // Update counters
    updatePermissionCounters();
}

function updatePermissionCounters() {
    // Update summary counters based on current checkbox states
    const totalMenus = $('.menu-item').length;
    const accessibleMenus = $('.access-checkbox:checked').length;
    const addPermissions = $('.add-checkbox:checked').length;
    const editPermissions = $('.edit-checkbox:checked').length;
    const deletePermissions = $('.delete-checkbox:checked').length;
    const exportPermissions = $('.export-checkbox:checked').length;
    
    // Update summary display if exists
    $('.card-body h5').each(function(index) {
        const counts = [totalMenus, accessibleMenus, addPermissions, editPermissions, deletePermissions, exportPermissions];
        if (counts[index] !== undefined) {
            $(this).text(counts[index]);
        }
    });
}

function saveAllChanges() {
    if (Object.keys(pendingChanges).length === 0) {
        showAlert('info', 'No changes to save');
        return;
    }
    
    const saveButton = event.target;
    saveButton.disabled = true;
    saveButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    
    const menuPermissions = Object.keys(pendingChanges).map(menuCode => ({
        menu_code: menuCode,
        permissions: pendingChanges[menuCode]
    }));
    
    $.ajax({
        url: `/permissions/{{ $user->USERID }}/bulk-update`,
        method: 'POST',
        data: {
            menu_permissions: menuPermissions
        },
        success: function(response) {
            if (response.success) {
                showAlert('success', response.message);
                pendingChanges = {};
                $('.menu-item').removeClass('table-warning');
            } else {
                showAlert('error', response.message);
            }
        },
        error: function(xhr) {
            const response = xhr.responseJSON;
            showAlert('error', response?.message || 'Failed to save permissions');
        },
        complete: function() {
            saveButton.disabled = false;
            saveButton.innerHTML = '<i class="fas fa-save"></i> Save All Changes';
        }
    });
}

function selectAllAccess() {
    $('.access-checkbox').each(function() {
        if (!$(this).prop('checked')) {
            $(this).prop('checked', true);
            const menuCode = $(this).data('menu');
            updatePermission(menuCode, 'has_access', true);
        }
    });
}

function clearAllPermissions() {
    confirmAction('This will clear all permissions for this user.', function() {
        $('.permission-checkbox').prop('checked', false);
        $('.menu-item').each(function() {
            const menuCode = $(this).data('menu');
            ['has_access', 'add', 'edit', 'delete', 'print', 'export'].forEach(permission => {
                updatePermission(menuCode, permission, false);
            });
        });
    });
}

function selectLevelAccess(level) {
    $(`.level-${CSS.escape(level.toLowerCase().replace(/\s+/g, '-'))} .access-checkbox`).each(function() {
        if (!$(this).prop('checked')) {
            $(this).prop('checked', true);
            const menuCode = $(this).data('menu');
            updatePermission(menuCode, 'has_access', true);
        }
    });
}

function clearLevel(level) {
    const levelClass = level.toLowerCase().replace(/\s+/g, '-');
    $(`.level-${CSS.escape(levelClass)} .permission-checkbox`).prop('checked', false);
    $(`.level-${CSS.escape(levelClass)}`).each(function() {
        const menuCode = $(this).data('menu');
        if (menuCode) {
            ['has_access', 'add', 'edit', 'delete', 'print', 'export'].forEach(permission => {
                updatePermission(menuCode, permission, false);
            });
        }
    });
}

function toggleLevel(level) {
    const levelClass = level.toLowerCase().replace(/\s+/g, '-');
    const rows = $(`.level-${CSS.escape(levelClass)}`);
    const toggleBtn = $(`#toggle-${CSS.escape(levelClass)} i`);
    
    if (rows.is(':visible')) {
        rows.hide();
        toggleBtn.removeClass('fa-chevron-down').addClass('fa-chevron-right');
    } else {
        rows.show();
        toggleBtn.removeClass('fa-chevron-right').addClass('fa-chevron-down');
    }
}

function expandAll() {
    $('.menu-item').show();
    $('.menu-level button i').removeClass('fa-chevron-right').addClass('fa-chevron-down');
}

function collapseAll() {
    $('.menu-item').hide();
    $('.menu-level button i').removeClass('fa-chevron-down').addClass('fa-chevron-right');
}

function resetToDefault() {
    confirmAction('This will reset all permissions based on user level. All current permissions will be lost.', function() {
        $.ajax({
            url: `/permissions/{{ $user->USERID }}/reset-default`,
            method: 'POST',
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
                    setTimeout(() => location.reload(), 1500);
                } else {
                    showAlert('error', response.message);
                }
            },
            error: function(xhr) {
                const response = xhr.responseJSON;
                showAlert('error', response?.message || 'Failed to reset permissions');
            }
        });
    });
}

function copyFromUser() {
    $('#copyFromUserModal').modal('show');
}

function loadUsersForCopy() {
    $.ajax({
        url: '/users/select',
        method: 'GET',
        success: function(response) {
            const select = $('#sourceUserSelect');
            select.empty().append('<option value="">Select user...</option>');
            
            response.users.forEach(function(user) {
                if (user.id !== '{{ $user->USERID }}') {
                    select.append(`<option value="${user.id}">${user.text}</option>`);
                }
            });
        },
        error: function() {
            showAlert('error', 'Failed to load users');
        }
    });
}

function executeCopyFromUser() {
    const sourceUser = $('#sourceUserSelect').val();
    if (!sourceUser) {
        showAlert('warning', 'Please select a source user');
        return;
    }
    
    $.ajax({
        url: '/users/copy-permissions',
        method: 'POST',
        data: {
            from_user: sourceUser,
            to_user: '{{ $user->USERID }}'
        },
        success: function(response) {
            if (response.success) {
                showAlert('success', response.message);
                $('#copyFromUserModal').modal('hide');
                setTimeout(() => location.reload(), 1500);
            } else {
                showAlert('error', response.message);
            }
        },
        error: function(xhr) {
            const response = xhr.responseJSON;
            showAlert('error', response?.message || 'Failed to copy permissions');
        }
    });
}
</script>
@endpush

@push('styles')
<style>
.permission-matrix {
    max-height: 600px;
    overflow-y: auto;
}

.permission-checkbox {
    transform: scale(1.3);
}

.menu-level {
    position: sticky;
    top: 65px;
    z-index: 10;
}

.table thead th {
    position: sticky;
    top: 0;
    z-index: 20;
}

.menu-item.table-warning {
    background-color: rgba(255, 193, 7, 0.1) !important;
}
</style>
@endpush