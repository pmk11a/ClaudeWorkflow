<?php

namespace App\Services;

use App\Models\DbFLPASS;
use App\Models\DbFLMENU;
use App\Models\DbMENU;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Collection;
use InvalidArgumentException;

class UserPermissionService
{
    /**
     * Get user menu permissions with enhanced validation and type casting
     * Uses raw query for performance but adds proper validation and caching
     * 
     * @param string $userId User ID to get permissions for
     * @return Collection Collection of menu permissions with proper types
     * @throws InvalidArgumentException If user doesn't exist
     */
    public function getUserMenuPermissions(string $userId): Collection
    {
        // Validate user exists
        if (!DbFLPASS::find($userId)) {
            throw new InvalidArgumentException("User with ID '{$userId}' not found");
        }

        // Check cache first (5 minutes TTL)
        $cacheKey = "user_menu_permissions_{$userId}";
        
        return Cache::remember($cacheKey, 300, function () use ($userId) {
            $results = DB::select("
                SELECT 
                    A.USERID, 
                    B.L0, 
                    B.KODEMENU AS L1, 
                    B.Keterangan AS Caption, 
                    B.ACCESS, 
                    B.icon,
                    B.routename,
                    'fas fa-folder' as group_icon,
                    B.L0 as group_name,
                    A.HASACCESS, 
                    A.ISTAMBAH, 
                    A.ISKOREKSI, 
                    A.ISHAPUS, 
                    A.ISCETAK,
                    A.ISEXPORT, 
                    A.TIPE
                FROM DBFLMENU A
                LEFT OUTER JOIN DBMENU B ON B.KODEMENU = A.L1
                WHERE A.USERID = ?
                ORDER BY A.USERID, A.L1
            ", [$userId]);
            
            // Transform results with proper type casting
            return collect($results)->map(function ($item) {
                return (object) [
                    'USERID' => $item->USERID,
                    'L0' => $item->L0,
                    'L1' => $item->L1,
                    'Caption' => $item->Caption,
                    'ACCESS' => (bool) $item->ACCESS,
                    'icon' => $item->icon,
                    'routename' => $item->routename,
                    'group_icon' => $item->group_icon,
                    'HASACCESS' => (bool) $item->HASACCESS,
                    'ISTAMBAH' => (bool) $item->ISTAMBAH,
                    'ISKOREKSI' => (bool) $item->ISKOREKSI,
                    'ISHAPUS' => (bool) $item->ISHAPUS,
                    'ISCETAK' => (bool) $item->ISCETAK,
                    'ISEXPORT' => (bool) $item->ISEXPORT,
                    'TIPE' => $item->TIPE
                ];
            });
        });
    }

    /**
     * Get hierarchical menu structure with permissions
     */
    public function getUserMenuHierarchy(string $userId): array
    {
        $permissions = collect($this->getUserMenuPermissions($userId));
        $hierarchy = [];

        foreach ($permissions as $perm) {
            $l0 = $perm->L0 ?? 'Other';
            
            if (!isset($hierarchy[$l0])) {
                $hierarchy[$l0] = [
                    'level' => $l0,
                    'menus' => []
                ];
            }

            $hierarchy[$l0]['menus'][] = [
                'code' => $perm->L1,
                'caption' => $perm->Caption,
                'access' => $perm->ACCESS,
                'permissions' => [
                    'has_access' => (bool) $perm->HASACCESS,
                    'add' => (bool) $perm->ISTAMBAH,
                    'edit' => (bool) $perm->ISKOREKSI,
                    'delete' => (bool) $perm->ISHAPUS,
                    'print' => (bool) $perm->ISCETAK,
                    'export' => (bool) $perm->ISEXPORT,
                ],
                'type' => $perm->TIPE
            ];
        }

        return $hierarchy;
    }

    /**
     * Check if user has specific permission for menu with caching
     * 
     * @param string $userId User ID
     * @param string $menuCode Menu code to check
     * @param string $permission Permission type (access, add, edit, delete, print, export)
     * @return bool True if user has permission, false otherwise
     */
    public function hasMenuPermission(string $userId, string $menuCode, string $permission = 'access'): bool
    {
        $cacheKey = "user_permission_{$userId}_{$menuCode}_{$permission}";
        
        return Cache::remember($cacheKey, 300, function () use ($userId, $menuCode, $permission) {
            $userMenu = DbFLMENU::where('USERID', $userId)
                ->where('L1', $menuCode)
                ->first();

            if (!$userMenu) {
                return false;
            }

            switch ($permission) {
                case 'access':
                    return (bool) $userMenu->HASACCESS;
                case 'add':
                case 'create':
                    return (bool) $userMenu->ISTAMBAH;
                case 'edit':
                case 'update':
                    return (bool) $userMenu->ISKOREKSI;
                case 'delete':
                    return (bool) $userMenu->ISHAPUS;
                case 'print':
                    return (bool) $userMenu->ISCETAK;
                case 'export':
                    return (bool) $userMenu->ISEXPORT;
                default:
                    return false;
            }
        });
    }

    /**
     * Update user permission for specific menu with cache invalidation
     * 
     * @param string $userId User ID
     * @param string $menuCode Menu code
     * @param array $permissions Array of permissions to update
     * @return bool True if successful, false otherwise
     */
    public function updateUserPermission(string $userId, string $menuCode, array $permissions): bool
    {
        try {
            // Use updateOrCreate for cleaner approach
            $userMenu = DbFLMENU::updateOrCreate(
                [
                    'USERID' => $userId,
                    'L1' => $menuCode
                ],
                array_filter($permissions, function ($key) {
                    return in_array($key, [
                        'HASACCESS', 'ISTAMBAH', 'ISKOREKSI', 
                        'ISHAPUS', 'ISCETAK', 'ISEXPORT', 'TIPE'
                    ]);
                }, ARRAY_FILTER_USE_KEY)
            );

            // Clear related cache
            $this->clearUserPermissionCache($userId, $menuCode);
            
            return (bool) $userMenu;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Copy permissions from one user to another
     */
    public function copyUserPermissions(string $fromUserId, string $toUserId): bool
    {
        try {
            // Delete existing permissions for target user
            DbFLMENU::where('USERID', $toUserId)->delete();

            // Get source user permissions
            $sourcePermissions = DbFLMENU::where('USERID', $fromUserId)->get();

            // Copy to target user
            foreach ($sourcePermissions as $permission) {
                $newPermission = $permission->replicate();
                $newPermission->USERID = $toUserId;
                $newPermission->save();
            }

            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Get all available menus for permission assignment with caching
     * 
     * @return Collection Collection of all menus
     */
    public function getAllMenus(): Collection
    {
        return Cache::remember('all_menus', 600, function () {
            return DbMENU::select('KODEMENU', 'Keterangan', 'L0', 'ACCESS')
                ->where('ACCESS', 1) // Only active menus
                ->orderBy('L0')
                ->orderBy('KODEMENU')
                ->get();
        });
    }

    /**
     * Set default permissions for new user based on user level
     */
    public function setDefaultPermissions(string $userId, int $userLevel): bool
    {
        try {
            $menus = $this->getAllMenus();
            
            foreach ($menus as $menu) {
                $permission = new DbFLMENU();
                $permission->USERID = $userId;
                $permission->L1 = $menu->KODEMENU;
                
                // Set default permissions based on user level
                if ($userLevel >= 5) {
                    // Super Admin - full access
                    $permission->HASACCESS = true;
                    $permission->ISTAMBAH = true;
                    $permission->ISKOREKSI = true;
                    $permission->ISHAPUS = true;
                    $permission->ISCETAK = true;
                    $permission->ISEXPORT = true;
                } elseif ($userLevel >= 3) {
                    // Manager - read/write access
                    $permission->HASACCESS = true;
                    $permission->ISTAMBAH = true;
                    $permission->ISKOREKSI = true;
                    $permission->ISHAPUS = false;
                    $permission->ISCETAK = true;
                    $permission->ISEXPORT = true;
                } else {
                    // Regular user - read only
                    $permission->HASACCESS = true;
                    $permission->ISTAMBAH = false;
                    $permission->ISKOREKSI = false;
                    $permission->ISHAPUS = false;
                    $permission->ISCETAK = true;
                    $permission->ISEXPORT = false;
                }
                
                $permission->save();
            }

            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Get permission summary for user
     */
    public function getUserPermissionSummary(string $userId): array
    {
        $permissions = $this->getUserMenuPermissions($userId);
        $total = count($permissions);
        
        $summary = [
            'total_menus' => $total,
            'accessible_menus' => 0,
            'add_permissions' => 0,
            'edit_permissions' => 0,
            'delete_permissions' => 0,
            'print_permissions' => 0,
            'export_permissions' => 0,
        ];

        foreach ($permissions as $perm) {
            if ($perm->HASACCESS) $summary['accessible_menus']++;
            if ($perm->ISTAMBAH) $summary['add_permissions']++;
            if ($perm->ISKOREKSI) $summary['edit_permissions']++;
            if ($perm->ISHAPUS) $summary['delete_permissions']++;
            if ($perm->ISCETAK) $summary['print_permissions']++;
            if ($perm->ISEXPORT) $summary['export_permissions']++;
        }

        return $summary;
    }

    /**
     * Get user menus with unlimited hierarchy levels using L0 column
     *
     * @param string $userId
     * @return array
     */
    public function getUserMenusUnlimited(string $userId): array
    {
        try {
            // Get all menu data from database including L0 level
            $menuData = DB::select("
                SELECT
                    A.USERID,
                    B.L0,
                    B.KODEMENU AS L1,
                    B.Keterangan AS Caption,
                    B.ACCESS,
                    A.HASACCESS,
                    A.ISTAMBAH,
                    A.ISKOREKSI,
                    A.ISHAPUS,
                    A.ISCETAK,
                    A.ISEXPORT,
                    A.TIPE,
                    B.routename,
                    B.icon
                FROM DBFLMENU A
                LEFT OUTER JOIN DBMENU B ON B.KODEMENU = A.L1
                WHERE A.USERID = ? AND A.HASACCESS = 1
                ORDER BY A.USERID, B.L0, A.L1
            ", [$userId]);

            // Convert to array and include L0 level information
            $menuItems = [];
            foreach ($menuData as $menu) {
                if ($menu->L0 != '0') { // Skip group headers
                    $menuItems[] = [
                        'code' => $menu->L1,
                        'title' => $menu->Caption,
                        'icon' => $menu->icon ?: 'fas fa-circle',
                        'route' => $this->resolveMenuRoute($menu->routename),
                        'l0_level' => (int) $menu->L0, // Include L0 level
                        'permissions' => [
                            'access' => (bool) $menu->HASACCESS,
                            'add' => (bool) $menu->ISTAMBAH,
                            'edit' => (bool) $menu->ISKOREKSI,
                            'delete' => (bool) $menu->ISHAPUS,
                            'print' => (bool) $menu->ISCETAK,
                            'export' => (bool) $menu->ISEXPORT
                        ]
                    ];
                }
            }

            // Build hierarchy using L0 levels
            return $this->buildHierarchyByL0($menuItems);

        } catch (\Exception $e) {
            \Log::error('Get User Menus Unlimited Error', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);

            return [];
        }
    }

    /**
     * Build hierarchy based on L0 levels from database
     * Uses L0 column to determine menu levels instead of code length
     */
    public function buildHierarchyByL0(array $menuItems): array
    {
        if (empty($menuItems)) {
            return [];
        }

        // Sort menu items by L0 level and code
        usort($menuItems, function($a, $b) {
            if ($a['l0'] === $b['l0']) {
                return strcmp($a['l1'], $b['l1']);
            }
            return $a['l0'] - $b['l0'];
        });

        // Build flat hierarchy first
        $hierarchy = [];
        $indexByCode = [];

        foreach ($menuItems as $item) {
            $menuItem = [
                'title' => $item['caption'],
                'code' => $item['l1'],
                'l0_level' => (int) $item['l0'],
                'icon' => $item['icon'] ?? 'fas fa-circle',
                'route' => $item['routename'] ?? null,
                'children' => []
            ];

            if ($item['l0'] == 1) {
                // Top level item
                $hierarchy[] = $menuItem;
                $indexByCode[$item['l1']] = &$hierarchy[count($hierarchy) - 1];
            } else if ($item['l0'] == 2) {
                // Find parent (previous item with L0 = 1)
                $parentFound = false;
                for ($i = count($hierarchy) - 1; $i >= 0; $i--) {
                    if ($hierarchy[$i]['l0_level'] == 1) {
                        $hierarchy[$i]['children'][] = $menuItem;
                        $parentFound = true;
                        break;
                    }
                }

                if (!$parentFound) {
                    // If no parent found, add as top level
                    $hierarchy[] = $menuItem;
                }
            }
        }

        return $hierarchy;
    }

    /**
     * Insert menu item into hierarchy based on L0 levels
     * Uses L0 column to determine parent-child relationships
     */
    private function insertIntoHierarchyByL0(array &$items, array $item, array $allMenuItems): void
    {
        $currentL0 = $item['l0_level'];

        // L0 = 1: Add at top level
        if ($currentL0 == 1) {
            $items[] = $item;
            return;
        }

        // L0 > 1: Find parent with L0 = currentL0 - 1
        $parentL0 = $currentL0 - 1;

        // Look for potential parent based on code prefix and L0 level
        for ($i = count($items) - 1; $i >= 0; $i--) {
            $existingItem = &$items[$i];

            // Check if this item could be a parent
            if (isset($existingItem['l0_level']) &&
                $existingItem['l0_level'] == $parentL0 &&
                strpos($item['code'], $existingItem['code']) === 0 &&
                strlen($item['code']) > strlen($existingItem['code'])) {

                // Initialize children if not exists
                if (!isset($existingItem['children'])) {
                    $existingItem['children'] = [];
                }

                // Recursively insert into submenu
                $this->insertIntoHierarchyByL0($existingItem['children'], $item, $allMenuItems);
                return;
            }
        }

        // If no parent found, add at current level (fallback)
        $items[] = $item;
    }

    /**
     * Insert menu item into hierarchy based on code pattern (legacy method)
     * Supports unlimited nesting levels with special handling for Berkas group
     */
    private function insertIntoHierarchy(array &$items, array $item): void
    {
        $code = $item['code'];
        $codeLength = strlen($code);

        // Special handling for Berkas group (00xxx codes)
        if (preg_match('/^00\d+$/', $code)) {
            // For Berkas group, only create hierarchy for codes with significant length difference
            // 00031 should NOT be submenu of 0003 - they should be at same level
            if ($codeLength <= 4) {
                // Codes 4 characters or less are at level 1 (0001, 0002, 0003, etc.)
                $items[] = $item;
                return;
            } else {
                // Codes longer than 4 characters, but check if they are really submenus
                // For now, treat all Berkas items as level 1
                $items[] = $item;
                return;
            }
        }

        // Find parent based on code prefix for non-Berkas groups
        $inserted = false;

        // Look for parent items (items with shorter codes that are prefixes)
        for ($i = count($items) - 1; $i >= 0; $i--) {
            $existingItem = &$items[$i];
            $existingCode = $existingItem['code'];
            $existingLength = strlen($existingCode);

            // Check if existing item is a potential parent
            if ($existingLength < $codeLength &&
                strpos($code, $existingCode) === 0) {

                // Initialize submenu if not exists
                if (!isset($existingItem['submenu'])) {
                    $existingItem['submenu'] = [];
                }

                // Recursively insert into submenu
                $this->insertIntoHierarchy($existingItem['submenu'], $item);
                $inserted = true;
                break;
            }
        }

        // If no parent found, add at current level
        if (!$inserted) {
            $items[] = $item;
        }
    }

    /**
     * Get user menus formatted for frontend (legacy method for backward compatibility)
     *
     * @param string $userId
     * @return array
     */
    public function getUserMenus(string $userId): array
    {
        try {
            // Use exact SQL query as provided by user
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
                WHERE A.USERID = ? AND A.HASACCESS = 1
                ORDER BY A.USERID, B.L0, A.L1
            ", [$userId]);

            // Build hierarchy from SQL query results
            $menuGroups = [];

            // Get all group headers from database (L0 = '0') - 7 groups: Berkas, Master Data, Accounting, Kepesertaan, Laporan, Utilitas, Jendela
            $groupHeaders = [];
            $dbGroups = DB::select("SELECT KODEMENU, Keterangan, icon FROM DBMENU WHERE L0 = '0' ORDER BY KODEMENU");
            foreach ($dbGroups as $group) {
                $groupHeaders[$group->KODEMENU] = [
                    'title' => $group->Keterangan,
                    'icon' => $group->icon ?: $this->getDefaultGroupIcon($group->KODEMENU)
                ];

                // Initialize all groups from database, even if empty
                $menuGroups[$group->KODEMENU] = [
                    'title' => $group->Keterangan,
                    'icon' => $group->icon ?: $this->getDefaultGroupIcon($group->KODEMENU),
                    'items' => []
                ];
            }

            // Map L0 to parent group codes - analyze from actual data
            $l0ToGroupMap = [
                '1' => '00',   // L0=1 items belong to Berkas (00)
                '2' => '09',   // L0=2 items belong to Jendela (09)
                // Note: Menu items with codes like 01001001, 02001, 03001, etc.
                // are placed in L0=1 but should be categorized by their prefix
            ];

            // Second pass: process menu items (L0 != 0)
            foreach ($menuData as $menu) {
                // Skip group headers
                if ($menu->L0 == '0') {
                    continue;
                }

                // Determine parent group based on menu code pattern
                $menuCode = $menu->L1;
                $parentGroupCode = $this->determineGroupByMenuCode($menuCode);

                // Fallback to L0 mapping if pattern doesn't match
                if (!isset($groupHeaders[$parentGroupCode])) {
                    $l0 = $menu->L0;
                    $parentGroupCode = $l0ToGroupMap[$l0] ?? '00'; // Default to Berkas
                }

                // Add menu item to group
                $menuGroups[$parentGroupCode]['items'][] = [
                    'code' => $menu->L1,
                    'title' => $menu->Caption,
                    'icon' => $menu->icon ?: 'fas fa-circle',
                    'route' => $menu->routename ?: '#',
                    'permissions' => [
                        'access' => (bool) $menu->HASACCESS,
                        'add' => (bool) $menu->ISTAMBAH,
                        'edit' => (bool) $menu->ISKOREKSI,
                        'delete' => (bool) $menu->ISHAPUS,
                        'print' => (bool) $menu->ISCETAK,
                        'export' => (bool) $menu->ISEXPORT
                    ]
                ];
            }
            
            // Post-process Jendela menu to create proper hierarchy
            $this->organizeJendelaMenu($menuGroups);

            // Convert to array format expected by frontend
            return array_values($menuGroups);
            
        } catch (\Exception $e) {
            \Log::error('Get User Menus Error', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);
            
            return [];
        }
    }

    /**
     * Determine group code based on menu code pattern
     *
     * @param string $menuCode Menu code from database
     * @return string Group code (00, 01, 02, 03, 08, 081, 09)
     */
    private function determineGroupByMenuCode(string $menuCode): string
    {
        // Basic menu items (0001-0008) belong to Berkas (00)
        if (preg_match('/^00\d+$/', $menuCode)) {
            return '00'; // Berkas
        }

        // Master Data items (01xxxxx) belong to Master Data (01)
        if (preg_match('/^01\d+/', $menuCode)) {
            return '01'; // Master Data
        }

        // Accounting items (02xxx) belong to Accounting (02)
        if (preg_match('/^02\d+/', $menuCode)) {
            return '02'; // Accounting
        }

        // Kepesertaan items (03xxx) belong to Kepesertaan (03)
        if (preg_match('/^03\d+/', $menuCode)) {
            return '03'; // Kepesertaan
        }

        // Utilitas items (081xx) belong to Utilitas (081) - check this FIRST before 08xxx
        if (preg_match('/^081\d*/', $menuCode)) {
            return '081'; // Utilitas
        }

        // Laporan items (08xxx) belong to Laporan (08) - check this AFTER 081
        if (preg_match('/^08\d+/', $menuCode)) {
            return '08'; // Laporan-laporan
        }

        // Jendela items (09xx) belong to Jendela (09)
        if (preg_match('/^09\d+/', $menuCode)) {
            return '09'; // Jendela
        }

        // Default fallback to Berkas
        return '00';
    }

    /**
     * Organize Jendela menu to create proper hierarchy:
     * - Tile should contain Horisontal and Vertikal as submenu
     */
    private function organizeJendelaMenu(array &$menuGroups): void
    {
        if (!isset($menuGroups['09'])) {
            return;
        }

        $jendelaItems = &$menuGroups['09']['items'];
        $reorganizedItems = [];
        $tileSubItems = [];

        foreach ($jendelaItems as $item) {
            if ($item['code'] === '09021' || $item['code'] === '09022') {
                // Horisontal and Vertikal belong to Tile
                $tileSubItems[] = $item;
            } else {
                $reorganizedItems[] = $item;

                // If this is Tile, add submenu structure
                if ($item['code'] === '0902') {
                    $lastIndex = count($reorganizedItems) - 1;
                    $reorganizedItems[$lastIndex]['submenu'] = [];
                }
            }
        }

        // Add Horisontal and Vertikal as submenu to Tile
        foreach ($reorganizedItems as &$item) {
            if ($item['code'] === '0902') {
                $item['submenu'] = $tileSubItems;
                break;
            }
        }

        $jendelaItems = $reorganizedItems;
    }

    /**
     * Get default icon for menu group
     *
     * @param string $groupCode Group code (00, 01, 02, 03, 08, 081, 09)
     * @return string Font Awesome icon class
     */
    private function getDefaultGroupIcon(string $groupCode): string
    {
        $iconMap = [
            '00' => 'fas fa-folder-open',      // Berkas
            '01' => 'fas fa-database',         // Master Data
            '02' => 'fas fa-calculator',       // Accounting
            '03' => 'fas fa-users',            // Kepesertaan
            '08' => 'fas fa-chart-bar',        // Laporan-laporan
            '081' => 'fas fa-tools',           // Utilitas
            '09' => 'fas fa-window-maximize'   // Jendela
        ];

        return $iconMap[$groupCode] ?? 'fas fa-folder';
    }

    /**
     * Get icon for menu based on code/title
     *
     * FALLBACK FUNCTION: Hanya digunakan jika kolom 'icon' di database DBMENU kosong/null
     * Prioritas: 1) Database icon, 2) Fallback dari mapping ini, 3) Default 'fas fa-circle'
     */
    private function getMenuIcon(string $code): string
    {
        $iconMap = [
            'MASTER DATA' => 'fas fa-database',
            'MASTER_CUSTOMER' => 'fas fa-users',
            'MASTER_SUPPLIER' => 'fas fa-truck',
            'MASTER_PRODUCT' => 'fas fa-box',
            'TRANSACTION' => 'fas fa-exchange-alt',
            'REPORT' => 'fas fa-chart-bar',
            'SYSTEM' => 'fas fa-cog',
            'USER' => 'fas fa-user',
            'PERMISSION' => 'fas fa-key'
        ];
        
        return $iconMap[$code] ?? 'fas fa-circle';
    }

    /**
     * Get route for menu
     * 
     * FALLBACK FUNCTION: Hanya digunakan jika kolom 'routename' di database DBMENU kosong/null
     * Prioritas: 1) Database routename, 2) Fallback dari mapping ini, 3) Default '#'
     */
    private function getMenuRoute(string $code): string
    {
        $routeMap = [
            'MASTER_CUSTOMER' => 'master/customer',
            'MASTER_SUPPLIER' => 'master/supplier',
            'MASTER_PRODUCT' => 'master/product',
            'USER_MANAGEMENT' => 'users',
            'PERMISSION_MANAGEMENT' => 'permissions'
        ];
        
        return $routeMap[$code] ?? strtolower(str_replace('_', '-', $code));
    }

    /**
     * Resolve menu route - check if it's a route name or direct URL
     */
    private function resolveMenuRoute(?string $routename): string
    {
        if (!$routename) {
            return '#';
        }

        try {
            // Check if it's a valid Laravel route name
            if (\Route::has($routename)) {
                return route($routename);
            }

            // If it starts with '/', treat as direct URL
            if (str_starts_with($routename, '/')) {
                return $routename;
            }

            // Otherwise, treat as direct URL but add leading slash if needed
            return '/' . ltrim($routename, '/');

        } catch (\Exception $e) {
            // If route resolution fails, return the original value with leading slash
            return str_starts_with($routename, '/') ? $routename : '/' . $routename;
        }
    }
}