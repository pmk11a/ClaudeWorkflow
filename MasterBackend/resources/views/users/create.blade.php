@extends('layouts.admin')

@section('title', 'Add User')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-0"><i class="fas fa-user-plus"></i> Add New User</h1>
        <p class="text-muted">Create a new system user</p>
    </div>
    <a href="{{ route('users.index') }}" class="btn btn-outline-secondary">
        <i class="fas fa-arrow-left"></i> Back to Users
    </a>
</div>

<form action="{{ route('users.store') }}" method="POST" id="createUserForm">
    @csrf
    
    <div class="row">
        <!-- User Information Card -->
        <div class="col-lg-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-user"></i> User Information</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="USERID" class="form-label">User ID <span class="text-danger">*</span></label>
                            <input type="text" class="form-control @error('USERID') is-invalid @enderror" 
                                   id="USERID" name="USERID" value="{{ old('USERID') }}" 
                                   placeholder="Enter unique user ID" maxlength="20" required>
                            <div class="form-text">Only letters, numbers, underscore, and dash allowed</div>
                            @error('USERID')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="FullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control @error('FullName') is-invalid @enderror" 
                                   id="FullName" name="FullName" value="{{ old('FullName') }}" 
                                   placeholder="Enter full name" maxlength="100" required>
                            @error('FullName')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="TINGKAT" class="form-label">User Level <span class="text-danger">*</span></label>
                            <select class="form-select @error('TINGKAT') is-invalid @enderror" 
                                    id="TINGKAT" name="TINGKAT" required>
                                <option value="">Select user level</option>
                                @if(session('user.TINGKAT') >= 1)
                                    <option value="1" {{ old('TINGKAT') == '1' ? 'selected' : '' }}>User (1)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 2)
                                    <option value="2" {{ old('TINGKAT') == '2' ? 'selected' : '' }}>Supervisor (2)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 3)
                                    <option value="3" {{ old('TINGKAT') == '3' ? 'selected' : '' }}>Manager (3)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 4)
                                    <option value="4" {{ old('TINGKAT') == '4' ? 'selected' : '' }}>Admin (4)</option>
                                @endif
                                @if(session('user.TINGKAT') >= 5)
                                    <option value="5" {{ old('TINGKAT') == '5' ? 'selected' : '' }}>Super Admin (5)</option>
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
                                       {{ old('STATUS', true) ? 'checked' : '' }}>
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
                                   id="kodeBag" name="kodeBag" value="{{ old('kodeBag') }}" 
                                   placeholder="Department code" maxlength="10">
                            @error('kodeBag')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                        
                        <div class="col-md-6">
                            <label for="KodeJab" class="form-label">Job Code</label>
                            <input type="text" class="form-control @error('KodeJab') is-invalid @enderror" 
                                   id="KodeJab" name="KodeJab" value="{{ old('KodeJab') }}" 
                                   placeholder="Job position code" maxlength="10">
                            @error('KodeJab')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Security & Permissions Card -->
        <div class="col-lg-4">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-lock"></i> Security</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label for="password" class="form-label">Password <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="password" class="form-control @error('password') is-invalid @enderror" 
                                   id="password" name="password" placeholder="Enter password" 
                                   minlength="6" required>
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
                    
                    <div class="mb-3">
                        <label for="password_confirmation" class="form-label">Confirm Password <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="password" class="form-control @error('password_confirmation') is-invalid @enderror" 
                                   id="password_confirmation" name="password_confirmation" 
                                   placeholder="Confirm password" required>
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
            
            <!-- Permission Settings Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-key"></i> Permissions</h5>
                </div>
                <div class="card-body">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="set_default_permissions" 
                               name="set_default_permissions" {{ old('set_default_permissions', true) ? 'checked' : '' }}>
                        <label class="form-check-label" for="set_default_permissions">
                            Set default permissions based on user level
                        </label>
                    </div>
                    <small class="form-text text-muted">
                        This will automatically assign menu permissions based on the selected user level. 
                        You can modify permissions later.
                    </small>
                </div>
            </div>
            
            <!-- Additional Codes Card -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-tags"></i> Additional Codes</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label for="KodeKasir" class="form-label">Cashier Code</label>
                        <input type="text" class="form-control @error('KodeKasir') is-invalid @enderror" 
                               id="KodeKasir" name="KodeKasir" value="{{ old('KodeKasir') }}" 
                               placeholder="Cashier code" maxlength="10">
                        @error('KodeKasir')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-0">
                        <label for="Kodegdg" class="form-label">Warehouse Code</label>
                        <input type="text" class="form-control @error('Kodegdg') is-invalid @enderror" 
                               id="Kodegdg" name="Kodegdg" value="{{ old('Kodegdg') }}" 
                               placeholder="Warehouse code" maxlength="10">
                        @error('Kodegdg')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
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
                    <i class="fas fa-save"></i> Create User
                </button>
            </div>
        </div>
    </div>
</form>
@endsection

@push('scripts')
<script>
$(document).ready(function() {
    // Convert User ID to uppercase
    $('#USERID').on('input', function() {
        $(this).val($(this).val().toUpperCase());
    });
    
    // Password strength indicator
    $('#password').on('input', function() {
        const password = $(this).val();
        const strength = checkPasswordStrength(password);
        
        // Remove existing strength indicators
        $(this).removeClass('is-valid border-warning border-danger');
        
        if (password.length > 0) {
            if (strength.score >= 3) {
                $(this).addClass('is-valid');
            } else if (strength.score >= 2) {
                $(this).addClass('border-warning');
            } else {
                $(this).addClass('border-danger');
            }
        }
    });
    
    // Form validation
    $('#createUserForm').on('submit', function(e) {
        const password = $('#password').val();
        const confirmPassword = $('#password_confirmation').val();
        
        if (password !== confirmPassword) {
            e.preventDefault();
            showAlert('error', 'Password confirmation does not match');
            $('#password_confirmation').focus();
            return false;
        }
        
        // Show loading state
        const submitBtn = $(this).find('button[type="submit"]');
        submitBtn.prop('disabled', true);
        submitBtn.html('<i class="fas fa-spinner fa-spin"></i> Creating User...');
    });
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

function checkPasswordStrength(password) {
    let score = 0;
    const checks = {
        length: password.length >= 8,
        lowercase: /[a-z]/.test(password),
        uppercase: /[A-Z]/.test(password),
        numbers: /\d/.test(password),
        symbols: /[^A-Za-z0-9]/.test(password)
    };
    
    score = Object.values(checks).filter(Boolean).length;
    
    return {
        score: score,
        checks: checks
    };
}
</script>
@endpush