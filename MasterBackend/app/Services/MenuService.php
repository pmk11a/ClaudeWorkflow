<?php

namespace App\Services;

use App\Services\UserPermissionService;
use Illuminate\Support\Collection;

class MenuService
{
    protected $permissionService;

    public function __construct(UserPermissionService $permissionService)
    {
        $this->permissionService = $permissionService;
    }

    /**
     * Get sidebar menu structure based on user permissions
     */
    public function getSidebarMenu(string $userId): array
    {
        $permissions = $this->permissionService->getUserMenuPermissions($userId);
        $menuStructure = $this->buildMenuStructure($permissions);
        
        return $menuStructure;
    }

    /**
     * Build hierarchical menu structure with icons and routes
     */
    private function buildMenuStructure(Collection $permissions): array
    {
        $menuItems = [];
        $grouped = $permissions->groupBy('L0');

        foreach ($grouped as $level0 => $items) {
            if (empty($level0)) {
                // Items without L0 (main menu items)
                foreach ($items as $item) {
                    if ($item->HASACCESS) {
                        $menuItems[] = $this->formatMenuItem($item);
                    }
                }
            } else {
                // Group header with submenu items
                $submenuItems = [];
                foreach ($items as $item) {
                    if ($item->HASACCESS) {
                        $submenuItems[] = $this->formatMenuItem($item);
                    }
                }

                if (!empty($submenuItems)) {
                    $firstItem = $items->first(); // Get first item for group data
                    
                    $menuItems[] = [
                        'type' => 'group',
                        'title' => $level0,
                        'icon' => $firstItem->group_icon ?: $this->getGroupIcon($level0),
                        'items' => $submenuItems
                    ];
                }
            }
        }

        return $menuItems;
    }

    /**
     * Format individual menu item
     */
    private function formatMenuItem($item): array
    {
        return [
            'type' => 'item',
            'title' => $item->Caption,
            'code' => $item->L1,
            'icon' => $item->icon ?: $this->getDefaultMenuIcon($item->L1),
            'route' => $item->routename ?: $this->getDefaultMenuRoute($item->L1),
            'permissions' => [
                'access' => (bool) $item->HASACCESS,
                'add' => (bool) $item->ISTAMBAH,
                'edit' => (bool) $item->ISKOREKSI,
                'delete' => (bool) $item->ISHAPUS,
                'print' => (bool) $item->ISCETAK,
                'export' => (bool) $item->ISEXPORT,
            ]
        ];
    }

    /**
     * Get icon for menu group
     */
    private function getGroupIcon(string $groupName): string
    {
        $iconMap = [
            'MASTER DATA' => 'fas fa-database',
            'ACCOUNTING' => 'fas fa-calculator',
            'BERKAS' => 'fas fa-folder-open',
            'PENGADAAN' => 'fas fa-shopping-cart',
            'MARKETING' => 'fas fa-bullhorn',
            'PRODUKSI' => 'fas fa-industry',
            'GUDANG' => 'fas fa-warehouse',
            'LAPORAN' => 'fas fa-chart-bar',
            'UTILITAS' => 'fas fa-tools',
            'JENDELA' => 'fas fa-window-maximize',
            'SYSTEM' => 'fas fa-cogs',
            'USER MANAGEMENT' => 'fas fa-users-cog',
        ];

        return $iconMap[strtoupper($groupName)] ?? 'fas fa-folder';
    }

    /**
     * Get default icon for individual menu item (fallback when database icon is empty)
     */
    private function getDefaultMenuIcon(string $menuCode): string
    {
        $iconMap = [
            // Dashboard
            'DASHBOARD' => 'fas fa-tachometer-alt',
            
            // Master Data
            'MASTER_CUSTOMER' => 'fas fa-users',
            'MASTER_SUPPLIER' => 'fas fa-truck',
            'MASTER_BARANG' => 'fas fa-boxes',
            'MASTER_KATEGORI' => 'fas fa-tags',
            
            // Accounting  
            'JURNAL_UMUM' => 'fas fa-book',
            'BUKU_BESAR' => 'fas fa-book-open',
            'NERACA' => 'fas fa-balance-scale',
            'LABA_RUGI' => 'fas fa-chart-line',
            
            // Berkas
            'BERKAS_MASUK' => 'fas fa-inbox',
            'BERKAS_KELUAR' => 'fas fa-paper-plane',
            'ARSIP' => 'fas fa-archive',
            
            // Pengadaan
            'PURCHASE_ORDER' => 'fas fa-file-invoice',
            'PENERIMAAN_BARANG' => 'fas fa-dolly',
            'RETUR_PEMBELIAN' => 'fas fa-undo',
            
            // Marketing
            'SALES_ORDER' => 'fas fa-handshake',
            'DELIVERY_ORDER' => 'fas fa-shipping-fast',
            'INVOICE' => 'fas fa-file-invoice-dollar',
            
            // Produksi
            'WORK_ORDER' => 'fas fa-tasks',
            'PRODUCTION' => 'fas fa-cogs',
            'QUALITY_CONTROL' => 'fas fa-check-circle',
            
            // Gudang
            'STOCK_OPNAME' => 'fas fa-clipboard-list',
            'MUTASI_BARANG' => 'fas fa-exchange-alt',
            'KARTU_STOK' => 'fas fa-list-alt',
            
            // Laporan
            'LAP_PENJUALAN' => 'fas fa-chart-area',
            'LAP_PEMBELIAN' => 'fas fa-chart-bar',
            'LAP_STOK' => 'fas fa-chart-pie',
            'LAP_KEUANGAN' => 'fas fa-money-check-alt',
            
            // User Management
            'USER_MGMT' => 'fas fa-users',
            'USER_PERMISSION' => 'fas fa-user-shield',
            'USER_ROLES' => 'fas fa-user-tag',
            
            // Utilitas
            'BACKUP' => 'fas fa-download',
            'RESTORE' => 'fas fa-upload',
            'SETTINGS' => 'fas fa-cog',
            'LOGS' => 'fas fa-file-alt',
        ];

        return $iconMap[$menuCode] ?? 'fas fa-circle';
    }

    /**
     * Get default route for menu item (fallback when database route is empty)
     */
    private function getDefaultMenuRoute(string $menuCode): string
    {
        $routeMap = [
            'DASHBOARD' => 'dashboard',
            'USER_MGMT' => 'users.index',
            'USER_PERMISSION' => 'permissions.bulk',
            // Add more route mappings as needed
        ];

        return $routeMap[$menuCode] ?? '#';
    }

    /**
     * Get user info for sidebar header
     */
    public function getUserInfo(string $userId): array
    {
        $user = \App\Models\DbFLPASS::find($userId);
        
        if (!$user) {
            return [
                'name' => 'Unknown User',
                'level' => 'Unknown',
                'avatar' => 'fas fa-user-circle'
            ];
        }

        return [
            'name' => $user->FullName,
            'level' => $user->getUserLevelName(),
            'avatar' => $this->getUserAvatar($user->TINGKAT),
            'department' => $user->kodeBag ?? 'N/A',
            'position' => $user->KodeJab ?? 'N/A'
        ];
    }

    /**
     * Get avatar icon based on user level
     */
    private function getUserAvatar(int $level): string
    {
        $avatarMap = [
            5 => 'fas fa-user-crown',     // Super Admin
            4 => 'fas fa-user-shield',    // Admin
            3 => 'fas fa-user-tie',       // Manager
            2 => 'fas fa-user-graduate',  // Supervisor
            1 => 'fas fa-user',           // User
        ];

        return $avatarMap[$level] ?? 'fas fa-user-circle';
    }
}