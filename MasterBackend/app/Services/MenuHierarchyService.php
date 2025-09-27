<?php

namespace App\Services;

use App\Models\DbFLPASS;
use App\Models\DbMENU;
use App\Models\DbFLMENU;
use Illuminate\Support\Facades\DB;

class MenuHierarchyService
{
    /**
     * Get hierarchical menu structure for a user
     */
    public function getUserMenuHierarchy(string $userId): array
    {
        // Raw SQL query as provided by user
        $menuData = DB::select("
            SELECT
                A.USERID,
                B.L0,                    -- Group from DBMENU
                B.KODEMENU AS L1,        -- Menu code from DBMENU
                B.Keterangan AS Caption, -- Menu name from DBMENU
                B.ACCESS,                -- Menu active status
                A.HASACCESS,             -- User access permission
                A.ISTAMBAH,              -- User add permission
                A.ISKOREKSI,             -- User edit permission
                A.ISHAPUS,               -- User delete permission
                A.ISCETAK,               -- User print permission
                A.ISEXPORT,              -- User export permission
                A.TIPE,                  -- Permission type
                B.routename,
                B.icon
            FROM DBFLMENU A
            LEFT OUTER JOIN DBMENU B ON B.KODEMENU = A.L1
            WHERE A.USERID = ? AND A.HASACCESS = 1 AND B.ACCESS = 1
            ORDER BY A.USERID, B.L0, A.L1
        ", [$userId]);

        return $this->buildHierarchy($menuData);
    }

    /**
     * Build hierarchical structure from flat menu data
     */
    private function buildHierarchy(array $menuData): array
    {
        $hierarchy = [];

        foreach ($menuData as $menu) {
            $groupKey = $menu->L0 ?? 'Others';

            // Initialize group if not exists
            if (!isset($hierarchy[$groupKey])) {
                $hierarchy[$groupKey] = [
                    'group' => $groupKey,
                    'children' => []
                ];
            }

            // Add menu item to group
            $hierarchy[$groupKey]['children'][] = [
                'menu_code' => $menu->L1,
                'caption' => $menu->Caption,
                'route_name' => $menu->routename,
                'icon' => $menu->icon,
                'permissions' => [
                    'access' => (bool) $menu->HASACCESS,
                    'add' => (bool) $menu->ISTAMBAH,
                    'edit' => (bool) $menu->ISKOREKSI,
                    'delete' => (bool) $menu->ISHAPUS,
                    'print' => (bool) $menu->ISCETAK,
                    'export' => (bool) $menu->ISEXPORT
                ],
                'type' => $menu->TIPE
            ];
        }

        // Convert to indexed array and sort
        return array_values($hierarchy);
    }

    /**
     * Get flat menu list for a user (for dropdown/select)
     */
    public function getUserMenuList(string $userId): array
    {
        return DB::select("
            SELECT
                B.KODEMENU as value,
                CONCAT(B.L0, ' - ', B.Keterangan) as label,
                B.L0 as group,
                A.HASACCESS
            FROM DBFLMENU A
            LEFT OUTER JOIN DBMENU B ON B.KODEMENU = A.L1
            WHERE A.USERID = ? AND A.HASACCESS = 1 AND B.ACCESS = 1
            ORDER BY B.L0, B.Keterangan
        ", [$userId]);
    }

    /**
     * Check if user has specific permission for a menu
     */
    public function hasPermission(string $userId, string $menuCode, string $permission = 'access'): bool
    {
        $userMenu = DbFLMENU::where('USERID', $userId)
            ->where('L1', $menuCode)
            ->first();

        if (!$userMenu) {
            return false;
        }

        return match($permission) {
            'access' => (bool) $userMenu->HASACCESS,
            'add', 'create' => (bool) $userMenu->ISTAMBAH,
            'edit', 'update' => (bool) $userMenu->ISKOREKSI,
            'delete' => (bool) $userMenu->ISHAPUS,
            'print' => (bool) $userMenu->ISCETAK,
            'export' => (bool) $userMenu->ISEXPORT,
            default => false
        };
    }

    /**
     * Get menu breadcrumb path
     */
    public function getMenuBreadcrumb(string $menuCode): array
    {
        $menu = DbMENU::where('KODEMENU', $menuCode)->first();

        if (!$menu) {
            return [];
        }

        return [
            [
                'label' => $menu->L0,
                'is_group' => true
            ],
            [
                'label' => $menu->Keterangan,
                'route' => $menu->routename,
                'is_group' => false
            ]
        ];
    }

    /**
     * Get all menu groups
     */
    public function getMenuGroups(): array
    {
        return DB::select("
            SELECT DISTINCT L0 as group_name, COUNT(*) as menu_count
            FROM DBMENU
            WHERE ACCESS = 1 AND L0 IS NOT NULL
            GROUP BY L0
            ORDER BY L0
        ");
    }

    /**
     * Search menus by keyword
     */
    public function searchMenus(string $userId, string $keyword): array
    {
        return DB::select("
            SELECT
                B.KODEMENU,
                B.Keterangan,
                B.L0,
                B.routename,
                B.icon,
                A.HASACCESS
            FROM DBFLMENU A
            LEFT OUTER JOIN DBMENU B ON B.KODEMENU = A.L1
            WHERE A.USERID = ?
                AND A.HASACCESS = 1
                AND B.ACCESS = 1
                AND (
                    B.Keterangan LIKE ?
                    OR B.KODEMENU LIKE ?
                    OR B.L0 LIKE ?
                )
            ORDER BY B.L0, B.Keterangan
        ", [$userId, "%{$keyword}%", "%{$keyword}%", "%{$keyword}%"]);
    }
}