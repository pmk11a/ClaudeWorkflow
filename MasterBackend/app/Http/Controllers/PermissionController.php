<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\DbFLPASS;
use App\Models\DbMENU;
use App\Services\UserPermissionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PermissionController extends Controller
{
    protected $permissionService;

    public function __construct(UserPermissionService $permissionService)
    {
        $this->permissionService = $permissionService;
    }

    /**
     * Display permission matrix for a user
     */
    public function matrix($userId)
    {
        $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
        $permissionHierarchy = $this->permissionService->getUserMenuHierarchy($userId);
        $allMenus = $this->permissionService->getAllMenus();
        $permissionSummary = $this->permissionService->getUserPermissionSummary($userId);

        return view('permissions.matrix', compact('user', 'permissionHierarchy', 'allMenus', 'permissionSummary'));
    }

    /**
     * Update user permissions (AJAX)
     */
    public function updatePermissions(Request $request, $userId)
    {
        $validator = Validator::make($request->all(), [
            'menu_code' => 'required|string|exists:DBMENU,KODEMENU',
            'permissions' => 'required|array',
            'permissions.has_access' => 'boolean',
            'permissions.add' => 'boolean',
            'permissions.edit' => 'boolean',
            'permissions.delete' => 'boolean',
            'permissions.print' => 'boolean',
            'permissions.export' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid data provided',
                'errors' => $validator->errors()
            ], 400);
        }

        try {
            $success = $this->permissionService->updateUserPermission(
                $userId,
                $request->menu_code,
                $request->permissions
            );

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'Permissions updated successfully!'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to update permissions'
                ], 500);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Bulk update permissions for multiple menus
     */
    public function bulkUpdatePermissions(Request $request, $userId)
    {
        $validator = Validator::make($request->all(), [
            'menu_permissions' => 'required|array',
            'menu_permissions.*.menu_code' => 'required|string|exists:DBMENU,KODEMENU',
            'menu_permissions.*.permissions' => 'required|array'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid data provided',
                'errors' => $validator->errors()
            ], 400);
        }

        try {
            $successCount = 0;
            $totalCount = count($request->menu_permissions);

            foreach ($request->menu_permissions as $menuPermission) {
                $success = $this->permissionService->updateUserPermission(
                    $userId,
                    $menuPermission['menu_code'],
                    $menuPermission['permissions']
                );

                if ($success) {
                    $successCount++;
                }
            }

            if ($successCount === $totalCount) {
                return response()->json([
                    'success' => true,
                    'message' => "All {$totalCount} permissions updated successfully!"
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => "Updated {$successCount} out of {$totalCount} permissions"
                ], 500);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Show bulk permission management page
     */
    public function bulk()
    {
        $users = DbFLPASS::select('USERID', 'FullName', 'TINGKAT', 'STATUS')
            ->where('STATUS', 1)
            ->orderBy('USERID')
            ->get();

        $allMenus = $this->permissionService->getAllMenus();

        return view('permissions.bulk', compact('users', 'allMenus'));
    }

    /**
     * Apply bulk permissions to multiple users
     */
    public function applyBulkPermissions(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'string|exists:DBFLPASS,USERID',
            'permission_action' => 'required|in:copy_from_user,set_by_level,custom_permissions',
            'source_user' => 'required_if:permission_action,copy_from_user|string|exists:DBFLPASS,USERID',
            'user_level' => 'required_if:permission_action,set_by_level|integer|min:1|max:5',
            'custom_permissions' => 'required_if:permission_action,custom_permissions|array'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid data provided',
                'errors' => $validator->errors()
            ], 400);
        }

        try {
            $successCount = 0;
            $totalUsers = count($request->user_ids);

            foreach ($request->user_ids as $userId) {
                $success = false;

                switch ($request->permission_action) {
                    case 'copy_from_user':
                        $success = $this->permissionService->copyUserPermissions(
                            $request->source_user,
                            $userId
                        );
                        break;

                    case 'set_by_level':
                        $success = $this->permissionService->setDefaultPermissions(
                            $userId,
                            $request->user_level
                        );
                        break;

                    case 'custom_permissions':
                        // Apply custom permissions to each menu
                        $success = true;
                        foreach ($request->custom_permissions as $menuCode => $permissions) {
                            $menuSuccess = $this->permissionService->updateUserPermission(
                                $userId,
                                $menuCode,
                                $permissions
                            );
                            if (!$menuSuccess) {
                                $success = false;
                            }
                        }
                        break;
                }

                if ($success) {
                    $successCount++;
                }
            }

            if ($successCount === $totalUsers) {
                return response()->json([
                    'success' => true,
                    'message' => "Permissions applied to all {$totalUsers} users successfully!"
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => "Applied permissions to {$successCount} out of {$totalUsers} users"
                ], 500);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get user permissions for comparison (AJAX)
     */
    public function getUserPermissions($userId)
    {
        try {
            $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
            $permissions = $this->permissionService->getUserMenuPermissions($userId);
            $hierarchy = $this->permissionService->getUserMenuHierarchy($userId);
            $summary = $this->permissionService->getUserPermissionSummary($userId);

            return response()->json([
                'success' => true,
                'data' => [
                    'user' => $user,
                    'permissions' => $permissions,
                    'hierarchy' => $hierarchy,
                    'summary' => $summary
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Check specific permission for user and menu
     */
    public function checkPermission($userId, $menuCode, $permission = 'access')
    {
        try {
            $hasPermission = $this->permissionService->hasMenuPermission($userId, $menuCode, $permission);

            return response()->json([
                'success' => true,
                'has_permission' => $hasPermission,
                'data' => [
                    'user_id' => $userId,
                    'menu_code' => $menuCode,
                    'permission' => $permission,
                    'result' => $hasPermission
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Reset user permissions to default based on user level
     */
    public function resetToDefault($userId)
    {
        try {
            $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
            
            // Delete existing permissions
            \App\Models\DbFLMENU::where('USERID', $userId)->delete();
            
            // Set default permissions based on user level
            $success = $this->permissionService->setDefaultPermissions($userId, $user->TINGKAT);

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'Permissions reset to default successfully!'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to reset permissions'
                ], 500);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Export user permissions to CSV
     */
    public function exportUserPermissions($userId)
    {
        try {
            $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
            $permissions = $this->permissionService->getUserMenuPermissions($userId);

            $filename = "permissions_{$userId}_" . date('Y-m-d_H-i-s') . '.csv';
            
            $headers = [
                'Content-Type' => 'text/csv',
                'Content-Disposition' => "attachment; filename=\"{$filename}\"",
            ];

            $callback = function() use ($user, $permissions) {
                $file = fopen('php://output', 'w');
                
                // CSV Header
                fputcsv($file, [
                    'User ID',
                    'Full Name',
                    'Menu Level 0',
                    'Menu Code',
                    'Menu Caption',
                    'Has Access',
                    'Can Add',
                    'Can Edit',
                    'Can Delete',
                    'Can Print',
                    'Can Export',
                    'Type'
                ]);

                // CSV Data
                foreach ($permissions as $perm) {
                    fputcsv($file, [
                        $perm->USERID,
                        $user->FullName,
                        $perm->L0,
                        $perm->L1,
                        $perm->Caption,
                        $perm->HASACCESS ? 'Yes' : 'No',
                        $perm->ISTAMBAH ? 'Yes' : 'No',
                        $perm->ISKOREKSI ? 'Yes' : 'No',
                        $perm->ISHAPUS ? 'Yes' : 'No',
                        $perm->ISCETAK ? 'Yes' : 'No',
                        $perm->ISEXPORT ? 'Yes' : 'No',
                        $perm->TIPE
                    ]);
                }

                fclose($file);
            };

            return response()->stream($callback, 200, $headers);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get menu hierarchy for permission assignment
     */
    public function getMenuHierarchy()
    {
        try {
            $menus = $this->permissionService->getAllMenus();
            $hierarchy = [];

            foreach ($menus as $menu) {
                $l0 = $menu->L0 ?? 'Other';
                
                if (!isset($hierarchy[$l0])) {
                    $hierarchy[$l0] = [
                        'level' => $l0,
                        'menus' => []
                    ];
                }

                $hierarchy[$l0]['menus'][] = [
                    'code' => $menu->KODEMENU,
                    'caption' => $menu->Keterangan,
                    'access' => $menu->ACCESS
                ];
            }

            return response()->json([
                'success' => true,
                'data' => $hierarchy
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}