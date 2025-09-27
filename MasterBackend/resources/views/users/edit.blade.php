@extends('layouts.admin')

@section('title', 'Edit User - ' . $user->USERID)

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-0"><i class="fas fa-user-edit"></i> Edit User</h1>
        <p class="text-muted">Modify user: <strong>{{ $user->USERID }}</strong></p>
    </div>
    <div class="btn-group">
        <a href="{{ route('users.show', $user->USERID) }}" class="btn btn-outline-info">
            <i class="fas fa-eye"></i> View Details
        </a>
        <a href="{{ route('permissions.matrix', $user->USERID) }}" class="btn btn-outline-success">
            <i class="fas fa-key"></i> Permissions
        </a>
        <a href="{{ route('users.index') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> Back to Users
        </a>
    </div>
</div>

<form action="{{ route('users.update', $user->USERID) }}" method="POST" id="editUserForm">
    @csrf
    @method('PUT')
    
    <div class="row">
        <!-- User Information Card -->
        <div class="col-lg-8">
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="fas fa-user"></i> User Information</h5>
                    <small class="text-muted">User ID cannot be changed</small>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="USERID" class="form-label">User ID</label>
                            <input type="text" class="form-control bg-light" id="USERID" 
                                   value="{{ $user->USERID }}" readonly>
                            <div class="form-text">User ID cannot be modified</div>
                        </div>
                        
                        <div class="col-md-6">
                            <label for="FullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control @error('FullName') is-invalid @enderror" 
                                   id="FullName" name="FullName" 
                                   value="{{ old('FullName', $user->FullName) }}" 
                                   placeholder="Enter full name" maxlength="100" required>
                            @error('FullName')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="TINGKAT" class="form-label">User Level <span class="text-danger">*</span></label>
                            <select class="form-select @error('TINGKAT') is-invalid @enderror" 
                                    id="TINGKAT" name="TINGKAT" required>
                                @if(session('user.TINGKAT') >= 1 || $user->TINGKAT >= 1)
                                    <option value="1" {{ old('TINGKAT', $user->TINGKAT) == '1' ? 'selected' : '' }}>User (1)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 2 || $user->TINGKAT >= 2)
                                    <option value="2" {{ old('TINGKAT', $user->TINGKAT) == '2' ? 'selected' : '' }}>Supervisor (2)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 3 || $user->TINGKAT >= 3)
                                    <option value="3" {{ old('TINGKAT', $user->TINGKAT) == '3' ? 'selected' : '' }}>Manager (3)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 4 || $user->TINGKAT >= 4)
                                    <option value="4" {{ old('TINGKAT', $user->TINGKAT) == '4' ? 'selected' : '' }}>Admin (4)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 5 || $user->TINGKAT >= 5)
                                    <option value="5" {{ old('TINGKAT', $user->TINGKAT) == '5' ? 'selected' : '' }}>Super Admin (5)</option>
                                @endif
                            </select>
                            @error('TINGKAT')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="STATUS" class="form-label">Status</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input @error('STATUS') is-invalid @enderror" 
                                       type="checkbox" id="STATUS" name="STATUS" 
                                       {{ old('STATUS', $user->STATUS) ? 'checked' : '' }}>
                                <label class="form-check-label" for="STATUS">
                                    Active User
                                </label>
                                @error('STATUS')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <label for="kodeBag" class="form-label">Department Code</label>
                            <input type="text" class="form-control @error('kodeBag') is-invalid @enderror" 
                                   id="kodeBag" name="kodeBag" 
                                   value="{{ old('kodeBag', $user->kodeBag) }}" 
                                   placeholder="Department code" maxlength="10">
                            @error('kodeBag')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="KodeJab" class="form-label">Job Code</label>
                            <input type="text" class="form-control @error('KodeJab') is-invalid @enderror" 
                                   id="KodeJab" name="KodeJab" 
                                   value="{{ old('KodeJab', $user->KodeJab) }}" 
                                   placeholder="Job position code" maxlength="10">
                            @error('KodeJab')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="KodeKasir" class="form-label">Cashier Code</label>
                            <input type="text" class="form-control @error('KodeKasir') is-invalid @enderror" 
                                   id="KodeKasir" name="KodeKasir" 
                                   value="{{ old('KodeKasir', $user->KodeKasir) }}" 
                                   placeholder="Cashier code" maxlength="10">
                            @error('KodeKasir')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="Kodegdg" class="form-label">Warehouse Code</label>
                            <input type="text" class="form-control @error('Kodegdg') is-invalid @enderror" 
                                   id="Kodegdg" name="Kodegdg" 
                                   value="{{ old('Kodegdg', $user->Kodegdg) }}" 
                                   placeholder="Warehouse code" maxlength="10">
                            @error('Kodegdg')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Security & System Info Card -->
        <div class="col-lg-4">
            <!-- Change Password Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-lock"></i> Change Password</h5>
                </div>
                <div class="card-body">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i> Leave blank to keep current password
                    </div>
                    
                    <div class="mb-3">
                        <label for="password" class="form-label">New Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control @error('password') is-invalid @enderror" 
                                   id="password" name="password" placeholder="Enter new password" 
                                   minlength="6">
                            <button class="btn btn-outline-secondary" type="button" 
                                    onclick="togglePassword('password')">
                                <i class="fas fa-eye" id="password-icon"></i>
                            </button>
                        </div>
                        <div class="form-text">Minimum 6 characters</div>
                        @error('password')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-0">
                        <label for="password_confirmation" class="form-label">Confirm New Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control @error('password_confirmation') is-invalid @enderror" 
                                   id="password_confirmation" name="password_confirmation" 
                                   placeholder="Confirm new password">
                            <button class="btn btn-outline-secondary" type="button" 
                                    onclick="togglePassword('password_confirmation')">
                                <i class="fas fa-eye" id="password_confirmation-icon"></i>
                            </button>
                        </div>
                        @error('password_confirmation')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>
            </div>
            
            <!-- System Information Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-info-circle"></i> System Information</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label for="HOSTID" class="form-label">Host ID</label>
                        <input type="text" class="form-control @error('HOSTID') is-invalid @enderror" 
                               id="HOSTID" name="HOSTID" 
                               value="{{ old('HOSTID', $user->HOSTID) }}" 
                               placeholder="Host ID" maxlength="50">
                        @error('HOSTID')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-0">
                        <label for="IPAddres" class="form-label">IP Address</label>
                        <input type="text" class="form-control @error('IPAddres') is-invalid @enderror" 
                               id="IPAddres" name="IPAddres" 
                               value="{{ old('IPAddres', $user->IPAddres) }}" 
                               placeholder="192.168.1.1">
                        @error('IPAddres')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>
            </div>
            
            <!-- Quick Actions Card -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-bolt"></i> Quick Actions</h5>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-2">
                        <a href="{{ route('permissions.matrix', $user->USERID) }}" 
                           class="btn btn-outline-success btn-sm">
                            <i class="fas fa-key"></i> Manage Permissions
                        </a>
                        <button type="button" class="btn btn-outline-warning btn-sm" 
                                onclick="resetToDefaultPermissions()">
                            <i class="fas fa-refresh"></i> Reset Permissions
                        </button>
                        <button type="button" class="btn btn-outline-info btn-sm" 
                                onclick="copyPermissionsModal()">
                            <i class="fas fa-copy"></i> Copy Permissions
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Form Actions -->
    <div class="card">
        <div class="card-body">
            <div class="d-flex justify-content-end gap-2">
                <a href="{{ route('users.index') }}" class="btn btn-outline-secondary">
                    <i class="fas fa-times"></i> Cancel
                </a>
                <button type="reset" class="btn btn-outline-warning">
                    <i class="fas fa-undo"></i> Reset
                </button>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update User
                </button>
            </div>
        </div>
    </div>
</form>

<!-- Copy Permissions Modal -->
<div class="modal fade" id="copyPermissionsModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-copy"></i> Copy Permissions</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Copy permissions from another user to <strong>{{ $user->USERID }}</strong>:</p>
                <div class="mb-3">
                    <label for="sourceUser" class="form-label">Source User</label>
                    <select class="form-select" id="sourceUser">
                        <option value="">Select user to copy from...</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="copyPermissions()">
                    <i class="fas fa-copy"></i> Copy Permissions
                </button>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {
    // Password confirmation validation
    $('#password_confirmation').on('input', function() {
        const password = $('#password').val();
        const confirmation = $(this).val();
        
        if (password && confirmation) {
            if (password === confirmation) {
                $(this).removeClass('is-invalid').addClass('is-valid');
            } else {
                $(this).removeClass('is-valid').addClass('is-invalid');
            }
        } else {
            $(this).removeClass('is-valid is-invalid');
        }
    });
    
    // Form validation
    $('#editUserForm').on('submit', function(e) {
        const password = $('#password').val();
        const confirmPassword = $('#password_confirmation').val();
        
        if (password && password !== confirmPassword) {
            e.preventDefault();
            showAlert('error', 'Password confirmation does not match');
            $('#password_confirmation').focus();
            return false;
        }
        
        // Show loading state
        const submitBtn = $(this).find('button[type="submit"]');
        submitBtn.prop('disabled', true);
        submitBtn.html('<i class="fas fa-spinner fa-spin"></i> Updating User...');
    });
    
    // Load users for copy permissions
    loadUsersForCopyPermissions();
});

function togglePassword(fieldId) {
    const field = document.getElementById(fieldId);
    const icon = document.getElementById(fieldId + '-icon');
    
    if (field.type === 'password') {
        field.type = 'text';
        icon.className = 'fas fa-eye-slash';
    } else {
        field.type = 'password';
        icon.className = 'fas fa-eye';
    }
}

function resetToDefaultPermissions() {
    confirmAction('This will reset all permissions for this user based on their user level.', function() {
        $.ajax({
            url: `/permissions/{{ $user->USERID }}/reset-default`,
            method: 'POST',
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
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

function copyPermissionsModal() {
    $('#copyPermissionsModal').modal('show');
}

function loadUsersForCopyPermissions() {
    $.ajax({
        url: '/users/select',
        method: 'GET',
        success: function(response) {
            const select = $('#sourceUser');
            select.empty().append('<option value="">Select user to copy from...</option>');
            
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

function copyPermissions() {
    const sourceUser = $('#sourceUser').val();
    if (!sourceUser) {
        showAlert('warning', 'Please select a source user');
        return;
    }
    
    confirmAction(`This will replace all current permissions for {{ $user->USERID }} with permissions from the selected user.`, function() {
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
                    $('#copyPermissionsModal').modal('hide');
                } else {
                    showAlert('error', response.message);
                }
            },
            error: function(xhr) {
                const response = xhr.responseJSON;
                showAlert('error', response?.message || 'Failed to copy permissions');
            }
        });
    });
}
</script>
@endpush