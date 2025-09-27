<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PermissionController;
use App\Http\Controllers\MenuController;
use App\Http\Controllers\MenuManagementController;
use App\Http\Controllers\LaporanController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Authentication routes (public)
Route::post('/login', [AuthController::class, 'apiLogin']);

// Protected routes (require authentication)
Route::middleware('token.auth')->group(function () {
    
    // Authentication & User Info
    Route::post('/logout', [AuthController::class, 'apiLogout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/check-permission', [AuthController::class, 'checkPermission']);
    Route::get('/auth/menus', [AuthController::class, 'getUserMenus']);
    
    // Dashboard
    Route::get('/dashboard', function (Request $request) {
        $user = $request->user();
        return response()->json([
            'success' => true,
            'message' => 'Dashboard data loaded successfully',
            'user' => $user ? [
                'USERID' => $user->USERID,
                'FullName' => $user->FullName,
                'TINGKAT' => $user->TINGKAT,
                'STATUS' => $user->STATUS,
            ] : null,
            'timestamp' => now(),
            'stats' => [
                'total_users' => 245,
                'active_sessions' => 12,
                'system_status' => 'online',
                'last_backup' => now()->subHours(3)->format('Y-m-d H:i:s')
            ]
        ]);
    });
    
    // User Management API (require level 3+)
    Route::middleware('can:manage-users')->group(function () {
        Route::apiResource('users', UserController::class);
        Route::post('/users/{user}/toggle-status', [UserController::class, 'toggleStatus']);
        Route::post('/users/copy-permissions', [UserController::class, 'copyPermissions']);
        Route::get('/users-select', [UserController::class, 'getUsersForSelect']);
        Route::get('/users-export', [UserController::class, 'export']);
    });
    
    // Permission Management API (require level 4+)
    Route::middleware('can:manage-permissions')->group(function () {
        Route::get('/permissions/{user}', [PermissionController::class, 'getUserPermissions']);
        Route::post('/permissions/{user}/update', [PermissionController::class, 'updatePermissions']);
        Route::post('/permissions/{user}/bulk-update', [PermissionController::class, 'bulkUpdatePermissions']);
        Route::post('/permissions/{user}/reset-default', [PermissionController::class, 'resetToDefault']);
        Route::get('/permissions/{user}/export', [PermissionController::class, 'exportUserPermissions']);
        Route::get('/permissions/{user}/{menuCode}/check/{permission?}', [PermissionController::class, 'checkPermission']);
        Route::get('/permissions/menu-hierarchy', [PermissionController::class, 'getMenuHierarchy']);
        Route::post('/permissions/bulk-apply', [PermissionController::class, 'applyBulkPermissions']);
    });
    
    // Menu Management API (all authenticated users)
    Route::prefix('menus')->group(function () {
        // Get user's menus based on privileges
        Route::get('/', [MenuController::class, 'getUserMenus']);
        Route::get('/sidebar', [MenuController::class, 'getSidebarMenu']);
        Route::get('/hierarchy', [MenuController::class, 'getMenuHierarchy']);

        // Permission checking
        Route::get('/check/{menuCode}/{permission?}', [MenuController::class, 'checkMenuPermission']);
        Route::get('/permissions/{userId?}', [MenuController::class, 'getMenuPermissions']);

        // Admin only - get all menus
        Route::get('/all', [MenuController::class, 'getAllMenus']);
    });

    // Dynamic Menu Management API (Admin only - level 4+)
    Route::prefix('menu-management')->group(function () {
        // CRUD operations for menus
        Route::get('/', [MenuManagementController::class, 'index']);
        Route::post('/', [MenuManagementController::class, 'store']);
        Route::get('/{menuCode}', [MenuManagementController::class, 'show']);
        Route::put('/{menuCode}', [MenuManagementController::class, 'update']);
        Route::delete('/{menuCode}', [MenuManagementController::class, 'destroy']);

        // Special operations
        Route::post('/{menuCode}/toggle-access', [MenuManagementController::class, 'toggleAccess']);
        Route::post('/reorder', [MenuManagementController::class, 'reorder']);

        // Helper endpoints
        Route::get('/icons/available', [MenuManagementController::class, 'getAvailableIcons']);
    });

    // Reports API (all authenticated users with report permissions)
    Route::prefix('reports')->group(function () {
        // Get available reports for user
        Route::get('/', [LaporanController::class, 'getAvailableReports']);

        // Get parameter form for specific report
        Route::get('/{reportCode}/parameters', [LaporanController::class, 'getReportParameters']);

        // Generate report preview
        Route::post('/{reportCode}/preview', [LaporanController::class, 'generatePreview']);

        // Export report to Excel/PDF
        Route::post('/{reportCode}/export', [LaporanController::class, 'exportReport']);

        // Download exported file
        Route::get('/download/{filename}', [LaporanController::class, 'downloadReport']);

        // Get report configuration (admin only)
        Route::get('/{reportCode}/config', [LaporanController::class, 'getReportConfig']);

        // Save report configuration (admin only)
        Route::post('/{reportCode}/config', [LaporanController::class, 'saveReportConfig']);
    });

    // Legacy: General Permission Check (all authenticated users) - Keep for backward compatibility
    Route::get('/permissions/{menuCode}/check/{permission?}', function(Request $request, $menuCode, $permission = 'access') {
        $permissionService = app(\App\Services\UserPermissionService::class);
        $user = $request->user();

        $hasPermission = $permissionService->hasMenuPermission($user->USERID, $menuCode, $permission);

        return response()->json([
            'success' => true,
            'has_permission' => $hasPermission,
            'menu_code' => $menuCode,
            'permission' => $permission,
            'user_id' => $user->USERID
        ]);
    });
});
