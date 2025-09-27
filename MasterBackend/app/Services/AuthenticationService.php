<?php

namespace App\Services;

use App\Models\DbFLPASS;
use App\DTOs\AuthResult;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class AuthenticationService
{
    private const MAX_LOGIN_ATTEMPTS = 5;
    private const LOCKOUT_DURATION = 15; // minutes

    public function __construct(
        private SecurityService $securityService
    ) {}

    /**
     * Attempt login with credentials
     */
    public function attemptLogin(array $credentials, bool $remember = false): AuthResult
    {
        $username = $credentials['username'];
        $password = $credentials['password'];

        Log::info('Login attempt', [
            'username' => $username,
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent()
        ]);

        // Check if user is locked out
        if ($this->securityService->isUserLockedOut($username)) {
            Log::warning('Login attempt on locked account', ['username' => $username]);
            return AuthResult::failed('Account temporarily locked due to too many failed attempts.');
        }

        // Find user
        $user = DbFLPASS::where('USERID', $username)->first();

        if (!$user) {
            $this->securityService->recordFailedAttempt($username);
            Log::warning('Login attempt with invalid username', ['username' => $username]);
            return AuthResult::failed('Invalid username or password.');
        }

        // Check if user is active
        if (!$user->STATUS) {
            Log::warning('Login attempt on inactive account', ['username' => $username]);
            return AuthResult::failed('Your account is inactive. Please contact administrator.');
        }

        // Verify password
        if (!$this->verifyPassword($password, $user->PASSWORD)) {
            $this->securityService->recordFailedAttempt($username);
            Log::warning('Login attempt with invalid password', ['username' => $username]);
            return AuthResult::failed('Invalid username or password.');
        }

        // Login successful
        $this->securityService->clearFailedAttempts($username);

        // Update last login
        $this->updateLastLogin($user);

        // Log in user
        Auth::login($user, $remember);

        Log::info('Successful login', [
            'user_id' => $user->USERID,
            'user_name' => $user->FullName,
            'user_level' => $user->TINGKAT
        ]);

        return AuthResult::successful($user);
    }

    /**
     * Attempt API login and return token
     */
    public function attemptApiLogin(array $credentials): AuthResult
    {
        $loginResult = $this->attemptLogin($credentials);

        if (!$loginResult->isSuccessful()) {
            return $loginResult;
        }

        $user = $loginResult->getUser();
        $token = $this->generateApiToken($user);

        return AuthResult::successful($user, $token);
    }

    /**
     * Logout user
     */
    public function logout($user): void
    {
        if ($user) {
            Log::info('User logout', [
                'user_id' => $user->USERID,
                'user_name' => $user->FullName
            ]);

            // Revoke API tokens if any
            $this->revokeApiTokens($user);
        }

        Auth::logout();
    }

    /**
     * Verify password against hash
     */
    private function verifyPassword(string $password, string $hash): bool
    {
        // Check if it's a Laravel hash
        if (Hash::needsRehash($hash)) {
            // Legacy password verification (if using plain text or different hashing)
            return $password === $hash;
        }

        return Hash::check($password, $hash);
    }

    /**
     * Update user's last login timestamp
     */
    private function updateLastLogin(DbFLPASS $user): void
    {
        try {
            $user->update([
                'last_login_at' => now(),
                'last_login_ip' => request()->ip()
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to update last login', [
                'user_id' => $user->USERID,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Generate API token for user
     */
    private function generateApiToken(DbFLPASS $user): string
    {
        // Create a simple token (in production, use Laravel Sanctum or Passport)
        $token = base64_encode($user->USERID . '|' . time() . '|' . Str::random(40));

        // Store token in session or cache for validation
        session(['api_token_' . $user->USERID => $token]);

        return $token;
    }

    /**
     * Revoke all API tokens for user
     */
    private function revokeApiTokens(DbFLPASS $user): void
    {
        // Remove from session
        session()->forget('api_token_' . $user->USERID);

        // If using database tokens, delete them here
        // $user->tokens()->delete();
    }

    /**
     * Validate API token
     */
    public function validateApiToken(string $token): ?DbFLPASS
    {
        try {
            $decoded = base64_decode($token);
            $parts = explode('|', $decoded);

            if (count($parts) !== 3) {
                return null;
            }

            [$userId, $timestamp, $random] = $parts;

            // Check if token exists in session
            $sessionToken = session('api_token_' . $userId);
            if ($sessionToken !== $token) {
                return null;
            }

            // Check if token is not expired (24 hours)
            if ((time() - $timestamp) > 86400) {
                session()->forget('api_token_' . $userId);
                return null;
            }

            return DbFLPASS::where('USERID', $userId)
                ->where('STATUS', 1)
                ->first();

        } catch (\Exception $e) {
            Log::error('Token validation error', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Change user password
     */
    public function changePassword(DbFLPASS $user, string $currentPassword, string $newPassword): bool
    {
        if (!$this->verifyPassword($currentPassword, $user->PASSWORD)) {
            return false;
        }

        $user->update([
            'PASSWORD' => Hash::make($newPassword),
            'password_changed_at' => now()
        ]);

        Log::info('Password changed', ['user_id' => $user->USERID]);

        return true;
    }

    /**
     * Reset user password (admin function)
     */
    public function resetPassword(DbFLPASS $user, string $newPassword): bool
    {
        $user->update([
            'PASSWORD' => Hash::make($newPassword),
            'password_changed_at' => now(),
            'must_change_password' => true
        ]);

        Log::info('Password reset by admin', [
            'user_id' => $user->USERID,
            'reset_by' => auth()->user()?->USERID
        ]);

        return true;
    }
}