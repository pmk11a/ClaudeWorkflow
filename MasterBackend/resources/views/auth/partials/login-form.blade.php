{{--
    Login Form Partial

    Clean login form with validation and accessibility
--}}

<form id="loginForm" action="{{ route('login') }}" method="POST" class="needs-validation" novalidate>
    @csrf

    <!-- Username Field -->
    <div class="form-group">
        <label for="username">Username</label>
        <div class="input-group">
            <i class="input-icon fas fa-user"></i>
            <input
                type="text"
                id="username"
                name="username"
                value="{{ old('username') }}"
                placeholder="Enter your username"
                required
                autocomplete="username"
                maxlength="50"
            >
        </div>
        @error('username')
        <div class="invalid-feedback d-block">
            {{ $message }}
        </div>
        @enderror
    </div>

    <!-- Password Field -->
    <div class="form-group">
        <label for="password">Password</label>
        <div class="input-group">
            <i class="input-icon fas fa-lock"></i>
            <input
                type="password"
                id="password"
                name="password"
                placeholder="Enter your password"
                required
                autocomplete="current-password"
            >
            <button type="button" class="password-toggle" data-target="#password" title="Show password">
                <i class="fas fa-eye"></i>
            </button>
        </div>
        @error('password')
        <div class="invalid-feedback d-block">
            {{ $message }}
        </div>
        @enderror
    </div>

    <!-- Remember Me -->
    <div class="remember-me">
        <input type="checkbox" id="remember" name="remember" {{ old('remember') ? 'checked' : '' }}>
        <label for="remember">Remember me</label>
    </div>

    <!-- Submit Button -->
    <button type="submit" class="login-button">
        <span class="loading-spinner"></span>
        <span class="button-text">Sign In</span>
    </button>
</form>