<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Collection;

class MenuReportService
{
    /**
     * Get access code from menu code
     * Maps menu code (e.g. "0101") to access code (e.g. "101")
     *
     * @param string $menuCode
     * @return string|null
     */
    public function getAccessCodeFromMenuCode(string $menuCode): ?string
    {
        try {
            $menu = DB::table('dbmenureport')
                ->where('KODEMENU', $menuCode)
                ->first();

            return $menu ? $menu->ACCESS : null;
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Get hierarchical menu structure for reports
     *
     * @param string|null $userId User ID to filter by permissions (optional)
     * @return array
     */
    public function getReportMenuHierarchy($userId = null): array
    {
        // Get main menu structure from dbmenureport (all levels)
        $menus = DB::table('dbmenureport')
            ->orderBy('KODEMENU')
            ->get();

        // Get user permissions from dbflmenureport if userId provided
        $userPermissions = [];
        if ($userId) {
            $permissions = DB::table('dbflmenureport')
                ->where('UserID', $userId)
                ->get();

            foreach ($permissions as $perm) {
                $userPermissions[$perm->L1] = [
                    'access' => $perm->Access,
                    'design' => $perm->IsDesign,
                    'export' => $perm->Isexport
                ];
            }
        }

        // Build hierarchy
        $hierarchy = $this->buildMenuHierarchy($menus, $userPermissions);

        return $hierarchy;
    }

    /**
     * Build hierarchical menu structure based on KODEMENU length
     *
     * @param Collection $menus
     * @param array $userPermissions
     * @return array
     */
    private function buildMenuHierarchy(Collection $menus, array $userPermissions = []): array
    {
        $allMenus = [];
        $hierarchy = [];

        // First pass: create all menu items as flat array
        foreach ($menus as $menu) {
            $menuLevel = $this->getMenuLevelFromCode($menu->KODEMENU);

            $allMenus[$menu->KODEMENU] = [
                'code' => $menu->KODEMENU,
                'title' => $menu->Keterangan,
                'level' => $menuLevel,
                'group' => $menu->L0, // L0 is grouping, not hierarchy level
                'access_code' => $menu->ACCESS,
                'children' => [],
                'permissions' => $userPermissions[$menu->KODEMENU] ?? null,
                'has_access' => $this->checkAccess($menu->KODEMENU, $userPermissions),
                'is_report' => $this->isReportMenu($menu->Keterangan, $menuLevel, $menu->ACCESS)
            ];
        }

        // Second pass: build parent-child relationships based on code hierarchy
        foreach ($allMenus as $code => $menu) {
            if ($menu['level'] == 1) {
                // Top level (3 digits) - add to hierarchy root
                $hierarchy[$code] = &$allMenus[$code];
            } else {
                // Find parent based on code pattern and attach this menu as child
                $parentCode = $this->findParentByCodePattern($code, $allMenus);
                if ($parentCode && isset($allMenus[$parentCode])) {
                    $allMenus[$parentCode]['children'][$code] = &$allMenus[$code];
                }
            }
        }

        return $hierarchy;
    }

    /**
     * Get menu level based on KODEMENU length pattern
     *
     * @param string $code
     * @return int
     */
    private function getMenuLevelFromCode(string $code): int
    {
        $length = strlen($code);

        // Determine level based on code length pattern
        if ($length <= 3) {
            return 1; // 010, 020 = Level 1 (Main Categories)
        } elseif ($length <= 4) {
            return 2; // 0101, 0201 = Level 2 (Sub Categories)
        } elseif ($length <= 6) {
            return 3; // 020101, 020201 = Level 3 (Sub-Sub Categories)
        } else {
            return 4; // 02020101, 02071001 = Level 4+ (Reports/Functions)
        }
    }

    /**
     * Find parent based on code pattern hierarchy
     *
     * @param string $code
     * @param array $allMenus
     * @return string|null
     */
    private function findParentByCodePattern(string $code, array $allMenus): ?string
    {
        $length = strlen($code);

        // Based on code length, determine possible parent lengths
        $possibleParentLengths = [];

        if ($length == 4) {
            // 4-digit codes (0101, 0201) have 3-digit parents (010, 020)
            $possibleParentLengths = [3];
        } elseif ($length == 6) {
            // 6-digit codes (020101, 020201) have 4-digit parents (0201, 0202)
            $possibleParentLengths = [4];
        } elseif ($length >= 8) {
            // 8+ digit codes (02020101) have 6-digit parents (020201)
            $possibleParentLengths = [6];
        }

        // Try each possible parent length
        foreach ($possibleParentLengths as $parentLength) {
            $parentCode = substr($code, 0, $parentLength);
            if (isset($allMenus[$parentCode])) {
                return $parentCode;
            }
        }

        // Fallback: try decreasing lengths
        for ($length = strlen($code) - 1; $length > 0; $length--) {
            $parentCode = substr($code, 0, $length);
            if (isset($allMenus[$parentCode])) {
                return $parentCode;
            }
        }

        return null;
    }

    /**
     * Check if menu is a report based on title, level, and access code
     *
     * @param string $title
     * @param int $level
     * @param int $accessCode
     * @return bool
     */
    private function isReportMenu(string $title, int $level, int $accessCode = 0): bool
    {
        // Reports are determined by access codes (database-driven approach)
        // Items with access codes > 0 are functional menu items that should be displayed
        $hasAccessCode = $accessCode > 0;

        // Primary criterion: Any item with access code is a report/functional item
        if ($hasAccessCode) {
            return true;
        }

        // Secondary criterion: Report-like titles at appropriate levels
        $hasReportTitle = str_contains(strtolower($title), 'laporan') ||
                         str_contains(strtolower($title), 'report') ||
                         str_contains(strtolower($title), 'neraca') ||
                         str_contains(strtolower($title), 'laba rugi') ||
                         str_contains(strtolower($title), 'kas') ||
                         str_contains(strtolower($title), 'investasi') ||
                         str_contains(strtolower($title), 'jurnal') ||
                         str_contains(strtolower($title), 'buku');

        // Items with report-like titles at level 3+ are reports
        if ($hasReportTitle && $level >= 3) {
            return true;
        }

        // Special cases for OJK report patterns (they have specific access codes)
        $reportPatterns = [
            'L A K', 'L P H U', 'N R C', 'L P A N', 'L A N',
            'S H M', 'D P J K A', 'R S B N', 'O B L I', 'S U K U K',
            'R K S D', 'T A B', 'P K O M', 'Renbis'
        ];

        foreach ($reportPatterns as $pattern) {
            if (str_contains(strtoupper($title), $pattern)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check user access to menu
     *
     * @param string $menuCode
     * @param array $userPermissions
     * @return bool
     */
    private function checkAccess(string $menuCode, array $userPermissions): bool
    {
        if (empty($userPermissions)) {
            return true; // No user filtering, show all
        }

        return isset($userPermissions[$menuCode]) &&
               $userPermissions[$menuCode]['access'] == 1;
    }

    /**
     * Get only report menus (filtered)
     *
     * @param string|null $userId
     * @return array
     */
    public function getReportMenusOnly($userId = null): array
    {
        $hierarchy = $this->getReportMenuHierarchy($userId);

        // Filter to only include categories that have report children
        $reportHierarchy = [];

        foreach ($hierarchy as $categoryCode => $category) {
            $reportChildren = $this->filterReportChildren($category['children']);

            if (!empty($reportChildren)) {
                $category['children'] = $reportChildren;
                $reportHierarchy[$categoryCode] = $category;
            }
        }

        return $reportHierarchy;
    }

    /**
     * Filter children to only include reports
     *
     * @param array $children
     * @return array
     */
    private function filterReportChildren(array $children): array
    {
        $reportChildren = [];

        foreach ($children as $code => $child) {
            if ($child['is_report']) {
                $reportChildren[$code] = $child;
            } elseif (!empty($child['children'])) {
                // Check if this has report grandchildren
                $reportGrandchildren = $this->filterReportChildren($child['children']);
                if (!empty($reportGrandchildren)) {
                    $child['children'] = $reportGrandchildren;
                    $reportChildren[$code] = $child;
                }
            }
        }

        return $reportChildren;
    }

    /**
     * Get specific menu item by code
     *
     * @param string $menuCode
     * @return array|null
     */
    public function getMenuByCode(string $menuCode): ?array
    {
        $menu = DB::table('dbmenureport')
            ->where('KODEMENU', $menuCode)
            ->first();

        if (!$menu) {
            return null;
        }

        return [
            'code' => $menu->KODEMENU,
            'title' => $menu->Keterangan,
            'level' => $menu->L0,
            'access_code' => $menu->ACCESS,
            'is_report' => $this->isReportMenu($menu->Keterangan, $menu->L0)
        ];
    }

    /**
     * Get user permissions for a specific menu
     *
     * @param string $userId
     * @param string $menuCode
     * @return array|null
     */
    public function getUserMenuPermissions(string $userId, string $menuCode): ?array
    {
        $permission = DB::table('dbflmenureport')
            ->where('UserID', $userId)
            ->where('L1', $menuCode)
            ->first();

        if (!$permission) {
            return null;
        }

        return [
            'access' => (bool) $permission->Access,
            'design' => (bool) $permission->IsDesign,
            'export' => (bool) $permission->Isexport
        ];
    }
}