<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Services\UserPermissionService;
use App\Services\MenuService;
use App\Models\DbFLPASS;
use App\Models\DbMENU;
use App\Models\DbFLMENU;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class MenuController extends Controller
{
    protected $userPermissionService;
    protected $menuService;

    public function __construct(UserPermissionService $userPermissionService, MenuService $menuService)
    {
        $this->userPermissionService = $userPermissionService;
        $this->menuService = $menuService;
    }

    /**
     * Get user menus with privileges after login
     * API endpoint untuk mendapatkan menu sesuai hak akses user
     */
    public function getUserMenus(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated',
                    'menus' => []
                ], 401);
            }

            // Get user menus with hierarchical structure
            $menus = $this->userPermissionService->getUserMenus($user->USERID);

            // Get user info for sidebar
            $userInfo = $this->menuService->getUserInfo($user->USERID);

            return response()->json([
                'success' => true,
                'message' => 'Menus loaded successfully',
                'data' => [
                    'user_info' => $userInfo,
                    'menus' => $menus,
                    'total_groups' => count($menus),
                    'total_menus' => array_sum(array_map(function($group) {
                        return count($group['items']);
                    }, $menus))
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Get User Menus Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to load menus',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
                'menus' => []
            ], 500);
        }
    }

    /**
     * Check if user has specific permission for a menu
     */
    public function checkMenuPermission(Request $request, $menuCode, $permission = 'access')
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'has_permission' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $hasPermission = $this->userPermissionService->hasMenuPermission(
                $user->USERID,
                $menuCode,
                $permission
            );

            return response()->json([
                'success' => true,
                'has_permission' => $hasPermission,
                'menu_code' => $menuCode,
                'permission' => $permission,
                'user_id' => $user->USERID
            ]);

        } catch (\Exception $e) {
            Log::error('Check Menu Permission Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'menu_code' => $menuCode,
                'permission' => $permission,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'has_permission' => false,
                'message' => 'Failed to check permission',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Get detailed menu permissions for a user
     */
    public function getMenuPermissions(Request $request, $userId = null)
    {
        try {
            $requestingUser = $request->user();
            $targetUserId = $userId ?? $requestingUser->USERID;

            // Check if requesting user has permission to view other users' permissions
            if ($targetUserId !== $requestingUser->USERID) {
                if (!$this->userPermissionService->hasMenuPermission($requestingUser->USERID, 'USER_PERMISSION', 'access')) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Insufficient privileges to view other user permissions'
                    ], 403);
                }
            }

            $permissions = $this->userPermissionService->getUserMenuPermissions($targetUserId);
            $hierarchy = $this->userPermissionService->getUserMenuHierarchy($targetUserId);
            $summary = $this->userPermissionService->getUserPermissionSummary($targetUserId);

            return response()->json([
                'success' => true,
                'data' => [
                    'user_id' => $targetUserId,
                    'permissions' => $permissions,
                    'hierarchy' => $hierarchy,
                    'summary' => $summary
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Get Menu Permissions Error', [
                'requesting_user' => $requestingUser->USERID ?? 'unknown',
                'target_user' => $targetUserId,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get menu permissions',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Get all available menus (for admin purposes)
     */
    public function getAllMenus(Request $request)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'USER_PERMISSION', 'access')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to view all menus'
                ], 403);
            }

            $menus = $this->userPermissionService->getAllMenus();

            return response()->json([
                'success' => true,
                'data' => [
                    'menus' => $menus,
                    'total' => $menus->count()
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Get All Menus Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get all menus',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Get menu hierarchy structure for navigation
     */
    public function getMenuHierarchy(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            // Get hierarchical menu structure
            $hierarchy = $this->userPermissionService->getUserMenuHierarchy($user->USERID);

            return response()->json([
                'success' => true,
                'data' => [
                    'hierarchy' => $hierarchy,
                    'total_groups' => count($hierarchy)
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Get Menu Hierarchy Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get menu hierarchy',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Middleware helper to check menu access
     */
    public function requireMenuAccess($menuCode, $permission = 'access')
    {
        return function ($request, $next) use ($menuCode, $permission) {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Authentication required'
                ], 401);
            }

            if (!$this->userPermissionService->hasMenuPermission($user->USERID, $menuCode, $permission)) {
                return response()->json([
                    'success' => false,
                    'message' => "Insufficient privileges for {$menuCode} - {$permission}"
                ], 403);
            }

            return $next($request);
        };
    }

    /**
     * Get user's sidebar menu (formatted for frontend components)
     */
    public function getSidebarMenu(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            // Use MenuService for properly formatted sidebar menu
            $sidebarMenu = $this->menuService->getSidebarMenu($user->USERID);
            $userInfo = $this->menuService->getUserInfo($user->USERID);

            return response()->json([
                'success' => true,
                'data' => [
                    'user_info' => $userInfo,
                    'menu_items' => $sidebarMenu,
                    'timestamp' => now()->toISOString()
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Get Sidebar Menu Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to load sidebar menu',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }
}