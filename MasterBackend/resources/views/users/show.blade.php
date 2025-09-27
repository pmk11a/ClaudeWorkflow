@extends('layouts.admin')

@section('title', 'User Details - ' . $user->USERID)

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-0"><i class="fas fa-user"></i> User Details</h1>
        <p class="text-muted">View user information and permissions</p>
    </div>
    <div class="btn-group">
        <a href="{{ route('users.edit', $user->USERID) }}" class="btn btn-primary">
            <i class="fas fa-edit"></i> Edit User
        </a>
        <a href="{{ route('permissions.matrix', $user->USERID) }}" class="btn btn-success">
            <i class="fas fa-key"></i> Permissions
        </a>
        <a href="{{ route('users.index') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> Back to Users
        </a>
    </div>
</div>

<div class="row">
    <!-- User Information Card -->
    <div class="col-lg-4">
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-id-card"></i> User Information</h5>
            </div>
            <div class="card-body text-center">
                <div class="mb-3">
                    <i class="fas fa-user-circle fa-5x text-muted"></i>
                </div>
                
                <h4 class="mb-1">{{ $user->FullName }}</h4>
                <p class="text-muted mb-3">{{ $user->USERID }}</p>
                
                <div class="row text-center mb-3">
                    <div class="col">
                        <span class="badge bg-{{ $user->STATUS ? 'success' : 'danger' }} fs-6">
                            {{ $user->STATUS ? 'Active' : 'Inactive' }}
                        </span>
                    </div>
                </div>
                
                <div class="row text-center">
                    <div class="col">
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
                        <span class="badge bg-{{ $levelClass }} fs-6">
                            {{ $levelName }} ({{ $user->TINGKAT }})
                        </span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Contact & System Info -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-info-circle"></i> System Information</h5>
            </div>
            <div class="card-body">
                <table class="table table-borderless table-sm">
                    <tr>
                        <td class="text-muted">Department:</td>
                        <td>{{ $user->kodeBag ?: '-' }}</td>
                    </tr>
                    <tr>
                        <td class="text-muted">Job Code:</td>
                        <td>{{ $user->KodeJab ?: '-' }}</td>
                    </tr>
                    <tr>
                        <td class="text-muted">Cashier Code:</td>
                        <td>{{ $user->KodeKasir ?: '-' }}</td>
                    </tr>
                    <tr>
                        <td class="text-muted">Warehouse Code:</td>
                        <td>{{ $user->Kodegdg ?: '-' }}</td>
                    </tr>
                    <tr>
                        <td class="text-muted">Host ID:</td>
                        <td>{{ $user->HOSTID ?: '-' }}</td>
                    </tr>
                    <tr>
                        <td class="text-muted">IP Address:</td>
                        <td>
                            @if($user->IPAddres)
                                <code>{{ $user->IPAddres }}</code>
                            @else
                                -
                            @endif
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-bolt"></i> Quick Actions</h5>
            </div>
            <div class="card-body">
                <div class="d-grid gap-2">
                    <a href="{{ route('users.edit', $user->USERID) }}" class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-edit"></i> Edit User
                    </a>
                    <a href="{{ route('permissions.matrix', $user->USERID) }}" class="btn btn-outline-success btn-sm">
                        <i class="fas fa-key"></i> Manage Permissions
                    </a>
                    <button type="button" class="btn btn-outline-info btn-sm" onclick="exportUserPermissions()">
                        <i class="fas fa-download"></i> Export Permissions
                    </button>
                    <hr>
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" id="userStatus" 
                               {{ $user->STATUS ? 'checked' : '' }}
                               onchange="toggleUserStatus('{{ $user->USERID }}', this.checked)">
                        <label class="form-check-label" for="userStatus">
                            User Active Status
                        </label>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Permission Overview -->
    <div class="col-lg-8">
        <!-- Permission Summary -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-chart-pie"></i> Permission Summary</h5>
            </div>
            <div class="card-body">
                @if(isset($permissionSummary))
                <div class="row g-3">
                    <div class="col-md-2 text-center">
                        <div class="border rounded p-3">
                            <h4 class="mb-0 text-primary">{{ $permissionSummary['total_menus'] }}</h4>
                            <small class="text-muted">Total Menus</small>
                        </div>
                    </div>
                    <div class="col-md-2 text-center">
                        <div class="border rounded p-3">
                            <h4 class="mb-0 text-success">{{ $permissionSummary['accessible_menus'] }}</h4>
                            <small class="text-muted">Accessible</small>
                        </div>
                    </div>
                    <div class="col-md-2 text-center">
                        <div class="border rounded p-3">
                            <h4 class="mb-0 text-info">{{ $permissionSummary['add_permissions'] }}</h4>
                            <small class="text-muted">Add Rights</small>
                        </div>
                    </div>
                    <div class="col-md-2 text-center">
                        <div class="border rounded p-3">
                            <h4 class="mb-0 text-warning">{{ $permissionSummary['edit_permissions'] }}</h4>
                            <small class="text-muted">Edit Rights</small>
                        </div>
                    </div>
                    <div class="col-md-2 text-center">
                        <div class="border rounded p-3">
                            <h4 class="mb-0 text-danger">{{ $permissionSummary['delete_permissions'] }}</h4>
                            <small class="text-muted">Delete Rights</small>
                        </div>
                    </div>
                    <div class="col-md-2 text-center">
                        <div class="border rounded p-3">
                            <h4 class="mb-0 text-secondary">{{ $permissionSummary['export_permissions'] }}</h4>
                            <small class="text-muted">Export Rights</small>
                        </div>
                    </div>
                </div>
                @else
                <div class="text-center text-muted">
                    <i class="fas fa-exclamation-circle fa-2x mb-2"></i><br>
                    No permission data available
                </div>
                @endif
            </div>
        </div>
        
        <!-- Permissions by Menu Level -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="fas fa-sitemap"></i> Menu Permissions</h5>
                <a href="{{ route('permissions.matrix', $user->USERID) }}" class="btn btn-sm btn-outline-success">
                    <i class="fas fa-edit"></i> Edit Permissions
                </a>
            </div>
            <div class="card-body">
                @if(isset($permissionHierarchy) && count($permissionHierarchy) > 0)
                <div class="accordion" id="permissionAccordion">
                    @foreach($permissionHierarchy as $level => $levelData)
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="heading{{ $loop->index }}">
                            <button class="accordion-button collapsed" type="button" 
                                    data-bs-toggle="collapse" data-bs-target="#collapse{{ $loop->index }}">
                                <i class="fas fa-folder me-2"></i>
                                <strong>{{ $level }}</strong>
                                <span class="badge bg-primary ms-2">{{ count($levelData['menus']) }} menus</span>
                            </button>
                        </h2>
                        <div id="collapse{{ $loop->index }}" class="accordion-collapse collapse" 
                             data-bs-parent="#permissionAccordion">
                            <div class="accordion-body">
                                <div class="table-responsive">
                                    <table class="table table-sm table-hover">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Menu</th>
                                                <th>Access</th>
                                                <th>Add</th>
                                                <th>Edit</th>
                                                <th>Delete</th>
                                                <th>Print</th>
                                                <th>Export</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach($levelData['menus'] as $menu)
                                            <tr>
                                                <td>
                                                    <strong>{{ $menu['code'] }}</strong><br>
                                                    <small class="text-muted">{{ $menu['caption'] }}</small>
                                                </td>
                                                <td>
                                                    <i class="fas fa-{{ $menu['permissions']['has_access'] ? 'check text-success' : 'times text-danger' }}"></i>
                                                </td>
                                                <td>
                                                    <i class="fas fa-{{ $menu['permissions']['add'] ? 'check text-success' : 'times text-muted' }}"></i>
                                                </td>
                                                <td>
                                                    <i class="fas fa-{{ $menu['permissions']['edit'] ? 'check text-success' : 'times text-muted' }}"></i>
                                                </td>
                                                <td>
                                                    <i class="fas fa-{{ $menu['permissions']['delete'] ? 'check text-danger' : 'times text-muted' }}"></i>
                                                </td>
                                                <td>
                                                    <i class="fas fa-{{ $menu['permissions']['print'] ? 'check text-info' : 'times text-muted' }}"></i>
                                                </td>
                                                <td>
                                                    <i class="fas fa-{{ $menu['permissions']['export'] ? 'check text-warning' : 'times text-muted' }}"></i>
                                                </td>
                                            </tr>
                                            @endforeach
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    @endforeach
                </div>
                @else
                <div class="text-center text-muted py-4">
                    <i class="fas fa-key fa-2x mb-2"></i><br>
                    No menu permissions configured
                    <div class="mt-2">
                        <a href="{{ route('permissions.matrix', $user->USERID) }}" class="btn btn-outline-success btn-sm">
                            <i class="fas fa-plus"></i> Set Permissions
                        </a>
                    </div>
                </div>
                @endif
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function toggleUserStatus(userId, isActive) {
    $.ajax({
        url: `/users/${userId}/toggle-status`,
        method: 'POST',
        success: function(response) {
            if (response.success) {
                showAlert('success', response.message);
                
                // Update status badge
                const statusBadge = $('.badge:contains("Active"), .badge:contains("Inactive")');
                if (isActive) {
                    statusBadge.removeClass('bg-danger').addClass('bg-success').text('Active');
                } else {
                    statusBadge.removeClass('bg-success').addClass('bg-danger').text('Inactive');
                }
            } else {
                showAlert('error', response.message);
                // Revert checkbox
                $('#userStatus').prop('checked', !isActive);
            }
        },
        error: function() {
            showAlert('error', 'Failed to update user status');
            // Revert checkbox
            $('#userStatus').prop('checked', !isActive);
        }
    });
}

function exportUserPermissions() {
    window.location.href = `/permissions/{{ $user->USERID }}/export`;
}
</script>
@endpush