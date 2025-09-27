<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

/**
 * Security Service
 * Handles security-related operations like rate limiting, lockouts, etc.
 */
class SecurityService
{
    private const MAX_ATTEMPTS = 5;
    private const LOCKOUT_DURATION = 15; // minutes
    private const ATTEMPT_CACHE_PREFIX = 'login_attempts:';
    private const LOCKOUT_CACHE_PREFIX = 'login_lockout:';

    /**
     * Record a failed login attempt
     */
    public function recordFailedAttempt(string $username): void
    {
        $key = $this->getAttemptKey($username);
        $attempts = Cache::get($key, 0) + 1;

        // Store attempts for 1 hour
        Cache::put($key, $attempts, 3600);

        Log::warning('Failed login attempt recorded', [
            'username' => $this->maskUsername($username),
            'attempts' => $attempts,
            'ip' => request()->ip()
        ]);

        // Lock user if max attempts reached
        if ($attempts >= self::MAX_ATTEMPTS) {
            $this->lockoutUser($username);
        }
    }

    /**
     * Clear failed attempts for user
     */
    public function clearFailedAttempts(string $username): void
    {
        $attemptKey = $this->getAttemptKey($username);
        $lockoutKey = $this->getLockoutKey($username);

        Cache::forget($attemptKey);
        Cache::forget($lockoutKey);

        Log::info('Failed attempts cleared', [
            'username' => $this->maskUsername($username)
        ]);
    }

    /**
     * Check if user is locked out
     */
    public function isUserLockedOut(string $username): bool
    {
        $lockoutKey = $this->getLockoutKey($username);
        return Cache::has($lockoutKey);
    }

    /**
     * Get remaining lockout time in minutes
     */
    public function getRemainingLockoutTime(string $username): int
    {
        $lockoutKey = $this->getLockoutKey($username);
        $lockoutUntil = Cache::get($lockoutKey);

        if (!$lockoutUntil) {
            return 0;
        }

        $remaining = ($lockoutUntil - time()) / 60;
        return max(0, ceil($remaining));
    }

    /**
     * Get current failed attempt count
     */
    public function getFailedAttemptCount(string $username): int
    {
        $key = $this->getAttemptKey($username);
        return Cache::get($key, 0);
    }

    /**
     * Get remaining attempts before lockout
     */
    public function getRemainingAttempts(string $username): int
    {
        $attempts = $this->getFailedAttemptCount($username);
        return max(0, self::MAX_ATTEMPTS - $attempts);
    }

    /**
     * Check if IP is rate limited
     */
    public function isIpRateLimited(string $ip = null): bool
    {
        $ip = $ip ?: request()->ip();
        $key = "ip_rate_limit:{$ip}";

        $attempts = Cache::get($key, 0);
        return $attempts >= 20; // Max 20 attempts per IP per hour
    }

    /**
     * Record IP attempt
     */
    public function recordIpAttempt(string $ip = null): void
    {
        $ip = $ip ?: request()->ip();
        $key = "ip_rate_limit:{$ip}";

        $attempts = Cache::get($key, 0) + 1;
        Cache::put($key, $attempts, 3600); // 1 hour
    }

    /**
     * Validate request security
     */
    public function validateRequestSecurity(): array
    {
        $issues = [];

        // Check for suspicious patterns
        $userAgent = request()->userAgent();
        if (empty($userAgent) || $this->isSuspiciousUserAgent($userAgent)) {
            $issues[] = 'Suspicious user agent';
        }

        // Check for too many requests from same IP
        if ($this->isIpRateLimited()) {
            $issues[] = 'Rate limit exceeded';
        }

        // Check for suspicious request patterns
        if ($this->hasSuspiciousHeaders()) {
            $issues[] = 'Suspicious headers detected';
        }

        return $issues;
    }

    /**
     * Lock out user
     */
    private function lockoutUser(string $username): void
    {
        $lockoutKey = $this->getLockoutKey($username);
        $lockoutUntil = time() + (self::LOCKOUT_DURATION * 60);

        Cache::put($lockoutKey, $lockoutUntil, self::LOCKOUT_DURATION * 60);

        Log::warning('User locked out', [
            'username' => $this->maskUsername($username),
            'lockout_duration' => self::LOCKOUT_DURATION . ' minutes',
            'ip' => request()->ip()
        ]);
    }

    /**
     * Get cache key for failed attempts
     */
    private function getAttemptKey(string $username): string
    {
        return self::ATTEMPT_CACHE_PREFIX . $username;
    }

    /**
     * Get cache key for lockout
     */
    private function getLockoutKey(string $username): string
    {
        return self::LOCKOUT_CACHE_PREFIX . $username;
    }

    /**
     * Mask username for logging
     */
    private function maskUsername(string $username): string
    {
        $length = strlen($username);

        if ($length <= 2) {
            return str_repeat('*', $length);
        }

        if ($length <= 4) {
            return $username[0] . str_repeat('*', $length - 2) . $username[-1];
        }

        return substr($username, 0, 2) . str_repeat('*', $length - 4) . substr($username, -2);
    }

    /**
     * Check for suspicious user agent
     */
    private function isSuspiciousUserAgent(string $userAgent): bool
    {
        $suspiciousPatterns = [
            'bot', 'crawler', 'spider', 'scraper',
            'curl', 'wget', 'python', 'java',
            'scanner', 'test'
        ];

        $userAgent = strtolower($userAgent);

        foreach ($suspiciousPatterns as $pattern) {
            if (strpos($userAgent, $pattern) !== false) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check for suspicious headers
     */
    private function hasSuspiciousHeaders(): bool
    {
        $request = request();

        // Check for missing common headers
        if (!$request->header('Accept') || !$request->header('Accept-Language')) {
            return true;
        }

        // Check for automation tools headers
        $suspiciousHeaders = [
            'X-Automated-Tool',
            'X-Scanner',
            'X-Test-Tool'
        ];

        foreach ($suspiciousHeaders as $header) {
            if ($request->header($header)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Generate security report
     */
    public function generateSecurityReport(): array
    {
        // Get recent failed attempts
        $recentAttempts = $this->getRecentFailedAttempts();

        // Get current lockouts
        $currentLockouts = $this->getCurrentLockouts();

        // Get IP statistics
        $ipStats = $this->getIpStatistics();

        return [
            'recent_failed_attempts' => $recentAttempts,
            'current_lockouts' => $currentLockouts,
            'ip_statistics' => $ipStats,
            'security_level' => $this->calculateSecurityLevel(),
            'generated_at' => now()->toISOString()
        ];
    }

    /**
     * Get recent failed attempts (placeholder - would need database logging)
     */
    private function getRecentFailedAttempts(): array
    {
        // This would typically query a database table
        // For now, return empty array
        return [];
    }

    /**
     * Get current lockouts (placeholder)
     */
    private function getCurrentLockouts(): array
    {
        // This would scan cache for lockout keys
        // For now, return empty array
        return [];
    }

    /**
     * Get IP statistics (placeholder)
     */
    private function getIpStatistics(): array
    {
        return [
            'unique_ips_today' => 0,
            'blocked_ips' => 0,
            'suspicious_requests' => 0
        ];
    }

    /**
     * Calculate security level
     */
    private function calculateSecurityLevel(): string
    {
        // Simple calculation based on various factors
        // In a real implementation, this would be more sophisticated
        return 'normal'; // 'low', 'normal', 'elevated', 'high'
    }
}