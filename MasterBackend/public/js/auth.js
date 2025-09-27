/**
 * DAPEN Authentication JavaScript
 * Clean JavaScript for login and authentication
 */

const DapenAuth = {
    // Configuration
    config: {
        loginForm: '#loginForm',
        loadingClass: 'loading',
        maxAttempts: 5,
        lockoutDuration: 15 * 60 * 1000 // 15 minutes
    },

    // Initialize
    init() {
        this.setupLoginForm();
        this.setupPasswordToggle();
        this.checkLockout();
        this.setupKeyboardShortcuts();
        console.log('DapenAuth initialized');
    },

    // Setup login form
    setupLoginForm() {
        const form = document.querySelector(this.config.loginForm);
        if (!form) return;

        form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin(form);
        });

        // Real-time validation
        const inputs = form.querySelectorAll('input');
        inputs.forEach(input => {
            input.addEventListener('blur', () => this.validateField(input));
            input.addEventListener('input', () => this.clearFieldError(input));
        });
    },

    // Handle login submission
    async handleLogin(form) {
        const submitBtn = form.querySelector('[type="submit"]');
        const username = form.querySelector('[name="username"]').value.trim();
        const password = form.querySelector('[name="password"]').value;

        // Clear previous errors
        this.clearErrors();

        // Validate inputs
        if (!this.validateForm(username, password)) {
            return;
        }

        // Check if user is locked out
        if (this.isLockedOut()) {
            this.showError('Too many failed attempts. Please try again later.');
            return;
        }

        // Show loading state
        this.showLoading(submitBtn);

        try {
            const formData = new FormData(form);

            const response = await fetch(form.action, {
                method: 'POST',
                body: formData,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content || ''
                }
            });

            const result = await response.json();

            if (result.success) {
                this.handleLoginSuccess(result);
            } else {
                this.handleLoginError(result.message || 'Login failed');
            }

        } catch (error) {
            console.error('Login error:', error);
            this.handleLoginError('Network error. Please check your connection.');
        } finally {
            this.hideLoading(submitBtn);
        }
    },

    // Validate form inputs
    validateForm(username, password) {
        let isValid = true;

        if (!username) {
            this.showFieldError('username', 'Username is required');
            isValid = false;
        } else if (username.length < 2) {
            this.showFieldError('username', 'Username must be at least 2 characters');
            isValid = false;
        }

        if (!password) {
            this.showFieldError('password', 'Password is required');
            isValid = false;
        } else if (password.length < 4) {
            this.showFieldError('password', 'Password must be at least 4 characters');
            isValid = false;
        }

        return isValid;
    },

    // Validate individual field
    validateField(field) {
        const value = field.value.trim();
        const name = field.getAttribute('name');

        this.clearFieldError(name);

        if (name === 'username') {
            if (!value) {
                this.showFieldError(name, 'Username is required');
                return false;
            } else if (value.length < 2) {
                this.showFieldError(name, 'Username must be at least 2 characters');
                return false;
            }
        }

        if (name === 'password') {
            if (!value) {
                this.showFieldError(name, 'Password is required');
                return false;
            } else if (value.length < 4) {
                this.showFieldError(name, 'Password must be at least 4 characters');
                return false;
            }
        }

        return true;
    },

    // Handle successful login
    handleLoginSuccess(result) {
        this.clearAttempts();
        this.showSuccess('Login successful! Redirecting...');

        // Redirect after short delay
        setTimeout(() => {
            window.location.href = result.redirect || '/dashboard';
        }, 1000);
    },

    // Handle login error
    handleLoginError(message) {
        this.incrementAttempts();
        this.showError(message);

        // Shake animation for form
        const container = document.querySelector('.login-container');
        if (container) {
            container.style.animation = 'shake 0.5s ease-in-out';
            setTimeout(() => {
                container.style.animation = '';
            }, 500);
        }

        // Clear password field
        const passwordField = document.querySelector('[name="password"]');
        if (passwordField) {
            passwordField.value = '';
            passwordField.focus();
        }
    },

    // Setup password visibility toggle
    setupPasswordToggle() {
        const toggleBtns = document.querySelectorAll('.password-toggle');

        toggleBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                const targetSelector = btn.getAttribute('data-target');
                const targetInput = document.querySelector(targetSelector);
                const icon = btn.querySelector('i');

                if (targetInput) {
                    if (targetInput.type === 'password') {
                        targetInput.type = 'text';
                        icon?.classList.remove('fa-eye');
                        icon?.classList.add('fa-eye-slash');
                        btn.setAttribute('title', 'Hide password');
                    } else {
                        targetInput.type = 'password';
                        icon?.classList.remove('fa-eye-slash');
                        icon?.classList.add('fa-eye');
                        btn.setAttribute('title', 'Show password');
                    }
                }
            });
        });
    },

    // Setup keyboard shortcuts
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Enter key submits form
            if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') {
                const form = document.querySelector(this.config.loginForm);
                if (form) {
                    e.preventDefault();
                    form.dispatchEvent(new Event('submit'));
                }
            }

            // Escape key clears form
            if (e.key === 'Escape') {
                this.clearForm();
            }
        });
    },

    // Lockout protection
    incrementAttempts() {
        const attempts = this.getAttempts() + 1;
        localStorage.setItem('login_attempts', attempts.toString());
        localStorage.setItem('last_attempt', Date.now().toString());

        if (attempts >= this.config.maxAttempts) {
            localStorage.setItem('lockout_until', (Date.now() + this.config.lockoutDuration).toString());
            this.showError(`Too many failed attempts. Please try again in ${this.config.lockoutDuration / (60 * 1000)} minutes.`);
        }
    },

    getAttempts() {
        return parseInt(localStorage.getItem('login_attempts') || '0');
    },

    clearAttempts() {
        localStorage.removeItem('login_attempts');
        localStorage.removeItem('last_attempt');
        localStorage.removeItem('lockout_until');
    },

    isLockedOut() {
        const lockoutUntil = localStorage.getItem('lockout_until');
        if (!lockoutUntil) return false;

        const lockoutTime = parseInt(lockoutUntil);
        return Date.now() < lockoutTime;
    },

    checkLockout() {
        if (this.isLockedOut()) {
            const lockoutUntil = parseInt(localStorage.getItem('lockout_until'));
            const remainingTime = Math.ceil((lockoutUntil - Date.now()) / (60 * 1000));
            this.showError(`Account temporarily locked. Try again in ${remainingTime} minutes.`);

            // Disable form
            const form = document.querySelector(this.config.loginForm);
            if (form) {
                const inputs = form.querySelectorAll('input, button');
                inputs.forEach(input => input.disabled = true);
            }
        }
    },

    // UI Helper Methods
    showLoading(button) {
        button.classList.add(this.config.loadingClass);
        button.disabled = true;

        const spinner = button.querySelector('.loading-spinner');
        if (spinner) {
            spinner.style.display = 'inline-block';
        }

        const originalText = button.textContent;
        button.setAttribute('data-original-text', originalText);
        button.textContent = 'Signing in...';
    },

    hideLoading(button) {
        button.classList.remove(this.config.loadingClass);
        button.disabled = false;

        const spinner = button.querySelector('.loading-spinner');
        if (spinner) {
            spinner.style.display = 'none';
        }

        const originalText = button.getAttribute('data-original-text');
        if (originalText) {
            button.textContent = originalText;
        }
    },

    showError(message) {
        this.removeExistingAlerts();

        const alertHtml = `
            <div class="alert alert-danger alert-dismissible" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i>
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        `;

        const form = document.querySelector(this.config.loginForm);
        if (form) {
            form.insertAdjacentHTML('afterbegin', alertHtml);
        }
    },

    showSuccess(message) {
        this.removeExistingAlerts();

        const alertHtml = `
            <div class="alert alert-success" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                ${message}
            </div>
        `;

        const form = document.querySelector(this.config.loginForm);
        if (form) {
            form.insertAdjacentHTML('afterbegin', alertHtml);
        }
    },

    showFieldError(fieldName, message) {
        const field = document.querySelector(`[name="${fieldName}"]`);
        if (!field) return;

        field.classList.add('is-invalid');

        // Remove existing error
        const existingError = field.parentNode.querySelector('.invalid-feedback');
        if (existingError) {
            existingError.remove();
        }

        // Add new error
        const errorDiv = document.createElement('div');
        errorDiv.className = 'invalid-feedback';
        errorDiv.textContent = message;
        field.parentNode.appendChild(errorDiv);
    },

    clearFieldError(fieldName) {
        const field = document.querySelector(`[name="${fieldName}"]`);
        if (!field) return;

        field.classList.remove('is-invalid');

        const error = field.parentNode.querySelector('.invalid-feedback');
        if (error) {
            error.remove();
        }
    },

    clearErrors() {
        // Clear form-level errors
        this.removeExistingAlerts();

        // Clear field-level errors
        const invalidFields = document.querySelectorAll('.is-invalid');
        invalidFields.forEach(field => {
            field.classList.remove('is-invalid');
        });

        const feedbacks = document.querySelectorAll('.invalid-feedback');
        feedbacks.forEach(feedback => feedback.remove());
    },

    removeExistingAlerts() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => alert.remove());
    },

    clearForm() {
        const form = document.querySelector(this.config.loginForm);
        if (form) {
            form.reset();
            this.clearErrors();
        }
    },

    // Handle server-side flash messages
    handleServerFlashMessages() {
        // This method will be called from the template to handle server messages
        // It's a cleaner approach than inline JavaScript in templates
        return {
            showError: (message) => this.showError(message),
            showSuccess: (message) => this.showSuccess(message)
        };
    },

    // Process flash messages from server (for template integration)
    processFlashMessages(messages) {
        if (!messages) return;

        if (messages.error) {
            this.showError(messages.error);
        }

        if (messages.success) {
            this.showSuccess(messages.success);
        }

        if (messages.errors && Array.isArray(messages.errors)) {
            messages.errors.forEach(error => this.showError(error));
        }
    }
};

// CSS for shake animation
const shakeStyle = document.createElement('style');
shakeStyle.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
    }
`;
document.head.appendChild(shakeStyle);

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    DapenAuth.init();
});

// Export for global access
window.DapenAuth = DapenAuth;