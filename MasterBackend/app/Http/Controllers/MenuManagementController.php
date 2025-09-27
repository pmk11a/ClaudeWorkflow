<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\DbMENU;
use App\Models\DbFLMENU;
use App\Models\DbFLPASS;
use App\Services\UserPermissionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\Rule;

class MenuManagementController extends Controller
{
    protected $userPermissionService;

    public function __construct(UserPermissionService $userPermissionService)
    {
        $this->userPermissionService = $userPermissionService;
    }

    /**
     * Get all menus for management (Admin only)
     */
    public function index(Request $request)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'MENU_MANAGEMENT', 'access')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to manage menus'
                ], 403);
            }

            $menus = DbMENU::orderBy('L0')
                ->orderBy('OL')
                ->orderBy('KODEMENU')
                ->get()
                ->map(function ($menu) {
                    return [
                        'KODEMENU' => $menu->KODEMENU,
                        'Keterangan' => $menu->Keterangan,
                        'L0' => $menu->L0,
                        'ACCESS' => (bool) $menu->ACCESS,
                        'OL' => $menu->OL,
                        'TipeTrans' => $menu->TipeTrans,
                        'icon' => $menu->icon,
                        'routename' => $menu->routename,
                        'is_group_header' => $menu->L0 === '0',
                        'total_users' => $menu->userPermissions()->count()
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => [
                    'menus' => $menus,
                    'total' => $menus->count(),
                    'groups' => $menus->where('is_group_header', true)->count(),
                    'items' => $menus->where('is_group_header', false)->count()
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Get All Menus Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get menus',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Store new menu in database
     */
    public function store(Request $request)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'MENU_MANAGEMENT', 'add')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to create menus'
                ], 403);
            }

            $request->validate([
                'KODEMENU' => [
                    'required',
                    'string',
                    'max:50',
                    'unique:DBMENU,KODEMENU',
                    'regex:/^[A-Z0-9_]+$/' // Only uppercase, numbers, and underscores
                ],
                'Keterangan' => 'required|string|max:100',
                'L0' => 'required|string|max:10',
                'ACCESS' => 'boolean',
                'OL' => 'nullable|integer|min:0|max:999',
                'TipeTrans' => 'nullable|string|max:20',
                'icon' => 'nullable|string|max:100',
                'routename' => 'nullable|string|max:100'
            ]);

            DB::beginTransaction();

            // Create menu
            $menu = DbMENU::create([
                'KODEMENU' => $request->KODEMENU,
                'Keterangan' => $request->Keterangan,
                'L0' => $request->L0,
                'ACCESS' => $request->ACCESS ?? true,
                'OL' => $request->OL ?? 0,
                'TipeTrans' => $request->TipeTrans,
                'icon' => $request->icon,
                'routename' => $request->routename
            ]);

            // Auto-create permissions for admin users (level 4+)
            if ($request->auto_assign_admin ?? true) {
                $adminUsers = DbFLPASS::where('TINGKAT', '>=', 4)->get();

                foreach ($adminUsers as $adminUser) {
                    DbFLMENU::create([
                        'USERID' => $adminUser->USERID,
                        'L1' => $menu->KODEMENU,
                        'HASACCESS' => true,
                        'ISTAMBAH' => true,
                        'ISKOREKSI' => true,
                        'ISHAPUS' => true,
                        'ISCETAK' => true,
                        'ISEXPORT' => true,
                        'TIPE' => $request->TipeTrans ?? 'MENU'
                    ]);
                }
            }

            DB::commit();

            // Clear cache
            $this->clearMenuCache();

            Log::info('Menu Created', [
                'created_by' => $user->USERID,
                'menu_code' => $menu->KODEMENU,
                'menu_name' => $menu->Keterangan
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Menu created successfully',
                'data' => [
                    'menu' => $menu,
                    'admin_permissions_created' => $adminUsers->count() ?? 0
                ]
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            DB::rollback();

            Log::error('Create Menu Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to create menu',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Show specific menu
     */
    public function show(Request $request, $menuCode)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'MENU_MANAGEMENT', 'access')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to view menu details'
                ], 403);
            }

            $menu = DbMENU::where('KODEMENU', $menuCode)->first();

            if (!$menu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Menu not found'
                ], 404);
            }

            // Get user permissions for this menu
            $userPermissions = DbFLMENU::where('L1', $menuCode)
                ->join('DBFLPASS', 'DBFLMENU.USERID', '=', 'DBFLPASS.USERID')
                ->select(
                    'DBFLMENU.*',
                    'DBFLPASS.FullName',
                    'DBFLPASS.TINGKAT'
                )
                ->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'menu' => $menu,
                    'user_permissions' => $userPermissions,
                    'total_users_with_access' => $userPermissions->where('HASACCESS', 1)->count(),
                    'is_group_header' => $menu->L0 === '0'
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Show Menu Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'menu_code' => $menuCode,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get menu details',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Update menu
     */
    public function update(Request $request, $menuCode)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'MENU_MANAGEMENT', 'edit')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to update menus'
                ], 403);
            }

            $menu = DbMENU::where('KODEMENU', $menuCode)->first();

            if (!$menu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Menu not found'
                ], 404);
            }

            $request->validate([
                'Keterangan' => 'required|string|max:100',
                'L0' => 'required|string|max:10',
                'ACCESS' => 'boolean',
                'OL' => 'nullable|integer|min:0|max:999',
                'TipeTrans' => 'nullable|string|max:20',
                'icon' => 'nullable|string|max:100',
                'routename' => 'nullable|string|max:100'
            ]);

            $menu->update([
                'Keterangan' => $request->Keterangan,
                'L0' => $request->L0,
                'ACCESS' => $request->ACCESS ?? $menu->ACCESS,
                'OL' => $request->OL ?? $menu->OL,
                'TipeTrans' => $request->TipeTrans,
                'icon' => $request->icon,
                'routename' => $request->routename
            ]);

            // Clear cache
            $this->clearMenuCache();

            Log::info('Menu Updated', [
                'updated_by' => $user->USERID,
                'menu_code' => $menu->KODEMENU,
                'menu_name' => $menu->Keterangan
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Menu updated successfully',
                'data' => ['menu' => $menu]
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Update Menu Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'menu_code' => $menuCode,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to update menu',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Delete menu
     */
    public function destroy(Request $request, $menuCode)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'MENU_MANAGEMENT', 'delete')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to delete menus'
                ], 403);
            }

            $menu = DbMENU::where('KODEMENU', $menuCode)->first();

            if (!$menu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Menu not found'
                ], 404);
            }

            DB::beginTransaction();

            // Delete all user permissions for this menu
            $deletedPermissions = DbFLMENU::where('L1', $menuCode)->count();
            DbFLMENU::where('L1', $menuCode)->delete();

            // Delete the menu
            $menu->delete();

            DB::commit();

            // Clear cache
            $this->clearMenuCache();

            Log::warning('Menu Deleted', [
                'deleted_by' => $user->USERID,
                'menu_code' => $menuCode,
                'menu_name' => $menu->Keterangan,
                'deleted_permissions' => $deletedPermissions
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Menu deleted successfully',
                'data' => [
                    'deleted_menu' => $menuCode,
                    'deleted_permissions' => $deletedPermissions
                ]
            ]);

        } catch (\Exception $e) {
            DB::rollback();

            Log::error('Delete Menu Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'menu_code' => $menuCode,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to delete menu',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Toggle menu access status
     */
    public function toggleAccess(Request $request, $menuCode)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'MENU_MANAGEMENT', 'edit')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to toggle menu access'
                ], 403);
            }

            $menu = DbMENU::where('KODEMENU', $menuCode)->first();

            if (!$menu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Menu not found'
                ], 404);
            }

            $menu->ACCESS = !$menu->ACCESS;
            $menu->save();

            // Clear cache
            $this->clearMenuCache();

            Log::info('Menu Access Toggled', [
                'toggled_by' => $user->USERID,
                'menu_code' => $menuCode,
                'new_status' => $menu->ACCESS ? 'active' : 'inactive'
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Menu access toggled successfully',
                'data' => [
                    'menu_code' => $menuCode,
                    'access_status' => (bool) $menu->ACCESS
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Toggle Menu Access Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'menu_code' => $menuCode,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to toggle menu access',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Reorder menus (change OL values)
     */
    public function reorder(Request $request)
    {
        try {
            $user = $request->user();

            // Check admin privileges
            if (!$this->userPermissionService->hasMenuPermission($user->USERID, 'MENU_MANAGEMENT', 'edit')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient privileges to reorder menus'
                ], 403);
            }

            $request->validate([
                'menus' => 'required|array',
                'menus.*.KODEMENU' => 'required|string|exists:DBMENU,KODEMENU',
                'menus.*.OL' => 'required|integer|min:0|max:999'
            ]);

            DB::beginTransaction();

            foreach ($request->menus as $menuData) {
                DbMENU::where('KODEMENU', $menuData['KODEMENU'])
                    ->update(['OL' => $menuData['OL']]);
            }

            DB::commit();

            // Clear cache
            $this->clearMenuCache();

            Log::info('Menus Reordered', [
                'reordered_by' => $user->USERID,
                'total_menus' => count($request->menus)
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Menus reordered successfully',
                'data' => [
                    'updated_menus' => count($request->menus)
                ]
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            DB::rollback();

            Log::error('Reorder Menus Error', [
                'user_id' => $user->USERID ?? 'unknown',
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to reorder menus',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    /**
     * Get available icons (for frontend form)
     */
    public function getAvailableIcons()
    {
        $icons = [
            // Dashboard & Analytics
            'fas fa-tachometer-alt' => 'Dashboard',
            'fas fa-chart-bar' => 'Chart Bar',
            'fas fa-chart-line' => 'Chart Line',
            'fas fa-chart-pie' => 'Chart Pie',
            'fas fa-chart-area' => 'Chart Area',

            // Database & Storage
            'fas fa-database' => 'Database',
            'fas fa-server' => 'Server',
            'fas fa-hdd' => 'Hard Drive',
            'fas fa-archive' => 'Archive',

            // Users & People
            'fas fa-users' => 'Users',
            'fas fa-user' => 'User',
            'fas fa-user-tie' => 'User Tie',
            'fas fa-user-shield' => 'User Shield',
            'fas fa-user-cog' => 'User Settings',

            // Business & Finance
            'fas fa-calculator' => 'Calculator',
            'fas fa-money-check-alt' => 'Money Check',
            'fas fa-coins' => 'Coins',
            'fas fa-credit-card' => 'Credit Card',
            'fas fa-file-invoice-dollar' => 'Invoice',

            // Inventory & Products
            'fas fa-boxes' => 'Boxes',
            'fas fa-box' => 'Box',
            'fas fa-warehouse' => 'Warehouse',
            'fas fa-truck' => 'Truck',
            'fas fa-dolly' => 'Dolly',

            // Documents & Files
            'fas fa-file-alt' => 'File',
            'fas fa-folder' => 'Folder',
            'fas fa-folder-open' => 'Folder Open',
            'fas fa-file-pdf' => 'PDF File',
            'fas fa-file-excel' => 'Excel File',

            // Actions & Tools
            'fas fa-cog' => 'Settings',
            'fas fa-cogs' => 'Settings Multiple',
            'fas fa-tools' => 'Tools',
            'fas fa-wrench' => 'Wrench',
            'fas fa-edit' => 'Edit',

            // Communication
            'fas fa-envelope' => 'Mail',
            'fas fa-phone' => 'Phone',
            'fas fa-comments' => 'Comments',
            'fas fa-bell' => 'Bell',

            // General
            'fas fa-home' => 'Home',
            'fas fa-circle' => 'Circle',
            'fas fa-square' => 'Square',
            'fas fa-star' => 'Star',
            'fas fa-heart' => 'Heart'
        ];

        return response()->json([
            'success' => true,
            'data' => ['icons' => $icons]
        ]);
    }

    /**
     * Clear menu-related cache
     */
    private function clearMenuCache()
    {
        Cache::forget('all_menus');

        // Clear user-specific menu caches
        $userIds = DbFLPASS::pluck('USERID');
        foreach ($userIds as $userId) {
            Cache::forget("user_menu_permissions_{$userId}");
        }
    }
}