<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Services\AuthenticationService;
use App\Services\UserPermissionService;
use App\Services\MenuHierarchyService;
use App\Models\DbFLPASS;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function __construct(
        private UserPermissionService $permissionService,
        private MenuHierarchyService $menuHierarchyService
    ) {}

    /**
     * Show login form
     */
    public function showLoginForm(): View
    {
        return view('auth.login');
    }

    /**
     * Handle login request (keeping existing logic for compatibility)
     */
    public function login(Request $request): RedirectResponse|JsonResponse
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        \Log::info('Login attempt started', [
            'username' => $request->username,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'environment' => app()->environment()
        ]);

        try {
            // Test database connection first
            try {
                \DB::connection()->getPdo();
                \Log::info('Database connection successful');
            } catch (\Exception $dbError) {
                \Log::error('Database connection failed', [
                    'error' => $dbError->getMessage(),
                    'host' => config('database.connections.sqlsrv.host'),
                    'database' => config('database.connections.sqlsrv.database')
                ]);
                return $this->handleFailedLogin($request, 'Database connection failed. Please contact administrator.');
            }

            // Find user in database
            $user = DbFLPASS::where('USERID', strtoupper($request->username))->first();

            \Log::info('User lookup result', [
                'username' => $request->username,
                'user_found' => $user ? true : false,
                'user_id' => $user ? $user->USERID : null,
                'user_status' => $user ? $user->STATUS : null
            ]);

            if (!$user) {
                \Log::warning('User not found', ['username' => $request->username]);
                return $this->handleFailedLogin($request, 'User not found.');
            }

            // Check if user is active
            if (!$user->STATUS) {
                \Log::warning('Inactive user login attempt', [
                    'username' => $request->username,
                    'status' => $user->STATUS
                ]);
                return $this->handleFailedLogin($request, 'User account is inactive. Please contact administrator.');
            }

            // Verify password using model's validatePassword method
            \Log::info('Password validation attempt', [
                'username' => $request->username,
                'has_uid2' => !empty($user->UID2),
                'uid2_length' => $user->UID2 ? strlen($user->UID2) : 0,
                'input_password_length' => strlen($request->password)
            ]);

            $passwordValid = $user->validatePassword($request->password);
            \Log::info('Password validation result', ['valid' => $passwordValid]);

            if (!$passwordValid) {
                \Log::warning('Invalid password', [
                    'username' => $request->username
                ]);
                return $this->handleFailedLogin($request, 'Invalid username or password.');
            }

            // Note: Skipping login tracking update as columns don't exist in legacy table
            // TODO: Add migration for last_login_at and login_count columns if needed

            // Log in the user
            auth()->login($user, $request->boolean('remember'));

            // Force session regeneration and save
            $request->session()->regenerate();
            $request->session()->save();

            \Log::info('Login successful', [
                'user_id' => $user->USERID,
                'user_name' => $user->FullName,
                'user_level' => $user->TINGKAT,
                'ip' => $request->ip(),
                'session_id' => session()->getId(),
                'auth_check' => auth()->check() ? 'true' : 'false'
            ]);

            return $this->handleSuccessfulLogin($request, $user);

        } catch (\Exception $e) {
            \Log::error('Login error', [
                'username' => $request->username,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return $this->handleFailedLogin($request, 'An error occurred during login. Please try again.');
        }
    }

    /**
     * Handle API login
     */
    public function apiLogin(Request $request): JsonResponse
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        \Log::info('API Login attempt started', [
            'username' => $request->username,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'environment' => app()->environment()
        ]);

        try {
            // Test database connection first
            try {
                \DB::connection()->getPdo();
                \Log::info('API Database connection successful');
            } catch (\Exception $dbError) {
                \Log::error('API Database connection failed', [
                    'error' => $dbError->getMessage(),
                    'host' => config('database.connections.sqlsrv.host'),
                    'database' => config('database.connections.sqlsrv.database')
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Database connection failed. Please contact administrator.'
                ], 500);
            }

            // Find user in database
            $user = DbFLPASS::where('USERID', strtoupper($request->username))->first();

            \Log::info('API User lookup result', [
                'username' => $request->username,
                'user_found' => $user ? true : false,
                'user_id' => $user ? $user->USERID : null,
                'user_status' => $user ? $user->STATUS : null
            ]);

            if (!$user) {
                \Log::warning('API User not found', ['username' => $request->username]);
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid credentials'
                ], 401);
            }

            // Check if user is active
            if (!$user->STATUS) {
                \Log::warning('API Inactive user login attempt', [
                    'username' => $request->username,
                    'status' => $user->STATUS
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'User account is inactive. Please contact administrator.'
                ], 401);
            }

            // Verify password using model's validatePassword method
            \Log::info('API Password validation attempt', [
                'username' => $request->username,
                'has_uid2' => !empty($user->UID2),
                'uid2_length' => $user->UID2 ? strlen($user->UID2) : 0,
                'input_password_length' => strlen($request->password)
            ]);

            $passwordValid = $user->validatePassword($request->password);
            \Log::info('API Password validation result', ['valid' => $passwordValid]);

            if (!$passwordValid) {
                \Log::warning('API Invalid password', [
                    'username' => $request->username
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid credentials'
                ], 401);
            }

            \Log::info('API Login successful', [
                'user_id' => $user->USERID,
                'user_name' => $user->FullName,
                'user_level' => $user->TINGKAT,
                'ip' => $request->ip()
            ]);

            // Return successful response without session handling
            // Generate simple token for API access
            $token = hash('sha256', $user->USERID . '_' . time() . '_' . random_int(1000, 9999));

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'user' => [
                    'USERID' => $user->USERID,
                    'FullName' => $user->FullName,
                    'TINGKAT' => $user->TINGKAT,
                    'STATUS' => $user->STATUS,
                ],
                'token' => $token,
                'permissions' => $this->permissionService->getUserPermissionSummary($user->USERID)
            ]);

        } catch (\Exception $e) {
            \Log::error('API Login error', [
                'username' => $request->username,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An error occurred during login. Please try again.'
            ], 500);
        }
    }

    /**
     * Handle logout
     */
    public function logout(Request $request): RedirectResponse
    {
        $user = auth()->user();

        if ($user) {
            \Log::info('User logout', [
                'user_id' => $user->USERID,
                'user_name' => $user->FullName
            ]);
        }

        auth()->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()
            ->route('login')
            ->with('success', 'You have been logged out successfully.');
    }

    /**
     * Handle API logout
     */
    public function apiLogout(Request $request): JsonResponse
    {
        $user = auth()->user();

        if ($user) {
            \Log::info('API logout', [
                'user_id' => $user->USERID,
                'user_name' => $user->FullName
            ]);
        }

        auth()->logout();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Get current user info
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not authenticated'
            ], 401);
        }

        return response()->json([
            'success' => true,
            'user' => [
                'USERID' => $user->USERID,
                'FullName' => $user->FullName,
                'TINGKAT' => $user->TINGKAT,
                'STATUS' => $user->STATUS,
                'kodeBag' => $user->kodeBag,
                'KodeJab' => $user->KodeJab,
                'last_login_at' => $user->last_login_at,
            ],
            'permissions' => $this->permissionService->getUserPermissionSummary($user->USERID)
        ]);
    }

    /**
     * Show dashboard
     */
    public function dashboard(Request $request): View|RedirectResponse
    {
        $user = $request->user();

        \Log::info('Dashboard access attempt', [
            'user_found' => $user ? 'true' : 'false',
            'user_id' => $user ? $user->USERID : 'null',
            'session_id' => session()->getId(),
            'auth_check' => auth()->check() ? 'true' : 'false',
            'session_data' => session()->all()
        ]);

        if (!$user) {
            \Log::warning('Dashboard accessed without authenticated user');
            return redirect()->route('login')->with('error', 'Please login to access dashboard.');
        }

        // Get user menus using existing working service
        $userMenus = $this->permissionService->getUserMenus($user->USERID);

        \Log::info('AuthController dashboard: userMenus count = ' . count($userMenus));

        // Also pass userMenus to view to ensure it's available in layout
        return view('dashboard', compact('user', 'userMenus'))->with('userMenus', $userMenus);
    }

    /**
     * Get user menus for API
     */
    public function getUserMenus(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not authenticated'
            ], 401);
        }

        $menus = $this->permissionService->getUserMenus($user->USERID);

        return response()->json([
            'success' => true,
            'menus' => $menus,
            'user' => [
                'USERID' => $user->USERID,
                'FullName' => $user->FullName,
                'TINGKAT' => $user->TINGKAT,
            ]
        ]);
    }

    /**
     * Check specific permission
     */
    public function checkPermission(Request $request): JsonResponse
    {
        $user = $request->user();
        $menuCode = $request->input('menu_code');
        $permission = $request->input('permission', 'access');

        if (!$user) {
            return response()->json([
                'success' => false,
                'has_permission' => false,
                'message' => 'User not authenticated'
            ], 401);
        }

        $hasPermission = $this->permissionService->hasMenuPermission(
            $user->USERID,
            $menuCode,
            $permission
        );

        return response()->json([
            'success' => true,
            'has_permission' => $hasPermission,
            'menu_code' => $menuCode,
            'permission' => $permission
        ]);
    }

    /**
     * Handle failed login attempt
     */
    private function handleFailedLogin(Request $request, string $errorMessage): RedirectResponse|JsonResponse
    {
        if ($request->expectsJson()) {
            return response()->json([
                'success' => false,
                'message' => $errorMessage
            ], 401);
        }

        return back()
            ->withInput($request->only('username', 'remember'))
            ->withErrors(['username' => $errorMessage]);
    }

    /**
     * Handle successful login
     */
    private function handleSuccessfulLogin(Request $request, $user): RedirectResponse|JsonResponse
    {
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'redirect' => route('dashboard'),
                'user' => [
                    'USERID' => $user->USERID,
                    'FullName' => $user->FullName,
                    'TINGKAT' => $user->TINGKAT,
                ]
            ]);
        }

        return redirect()
            ->intended(route('dashboard'))
            ->with('success', 'Welcome back, ' . $user->FullName . '!');
    }
}