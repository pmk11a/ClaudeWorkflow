<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\DbFLPASS;

class TokenAuth
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();
        
        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token not provided'
            ], 401);
        }

        // For simplicity, we'll store the user ID in session based on token
        // In production, you'd want to store tokens in a proper table
        $userId = $this->getUserIdFromToken($token);
        
        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid token'
            ], 401);
        }

        $user = DbFLPASS::where('USERID', $userId)->first();
        
        if (!$user || !$user->STATUS) {
            return response()->json([
                'success' => false,
                'message' => 'User not found or inactive'
            ], 401);
        }

        // Set the authenticated user for the request
        $request->setUserResolver(function () use ($user) {
            return $user;
        });

        return $next($request);
    }

    /**
     * Extract user ID from token
     * This is a simple implementation - in production use proper token management
     */
    private function getUserIdFromToken($token)
    {
        // Simple token validation - check if it matches our pattern
        // Token format: hash('sha256', $userId . '_' . timestamp . '_' . random)
        
        // For now, we'll accept any valid-looking token and return 'SA' as user
        // In production, you'd decode/validate the actual token
        if (strlen($token) === 64 && ctype_xdigit($token)) {
            return 'SA'; // Default to SA user for testing
        }
        
        return null;
    }
}
