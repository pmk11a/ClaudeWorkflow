<?php

namespace App\DTOs;

use App\Models\DbFLPASS;

/**
 * Data Transfer Object for Authentication Results
 * Provides a clean way to return authentication status and data
 */
class AuthResult
{
    private function __construct(
        private bool $successful,
        private ?DbFLPASS $user = null,
        private ?string $token = null,
        private ?string $errorMessage = null,
        private int $attemptsRemaining = 0
    ) {}

    /**
     * Create successful authentication result
     */
    public static function successful(DbFLPASS $user, ?string $token = null): self
    {
        return new self(
            successful: true,
            user: $user,
            token: $token
        );
    }

    /**
     * Create failed authentication result
     */
    public static function failed(string $errorMessage, int $attemptsRemaining = 0): self
    {
        return new self(
            successful: false,
            errorMessage: $errorMessage,
            attemptsRemaining: $attemptsRemaining
        );
    }

    /**
     * Check if authentication was successful
     */
    public function isSuccessful(): bool
    {
        return $this->successful;
    }

    /**
     * Get authenticated user
     */
    public function getUser(): ?DbFLPASS
    {
        return $this->user;
    }

    /**
     * Get authentication token
     */
    public function getToken(): ?string
    {
        return $this->token;
    }

    /**
     * Get error message
     */
    public function getErrorMessage(): ?string
    {
        return $this->errorMessage;
    }

    /**
     * Get remaining attempts before lockout
     */
    public function getAttemptsRemaining(): int
    {
        return $this->attemptsRemaining;
    }

    /**
     * Convert to array for API responses
     */
    public function toArray(): array
    {
        $result = [
            'success' => $this->successful
        ];

        if ($this->successful) {
            $result['user'] = $this->user?->toApiArray();
            if ($this->token) {
                $result['token'] = $this->token;
            }
        } else {
            $result['message'] = $this->errorMessage;
            if ($this->attemptsRemaining > 0) {
                $result['attempts_remaining'] = $this->attemptsRemaining;
            }
        }

        return $result;
    }
}