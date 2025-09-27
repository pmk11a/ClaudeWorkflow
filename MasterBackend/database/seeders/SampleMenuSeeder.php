<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\DbMENU;
use App\Models\DbFLMENU;
use App\Models\DbFLPASS;

class SampleMenuSeeder extends Seeder
{
    /**
     * Seed sample menu data to demonstrate dynamic menu system
     */
    public function run()
    {
        echo "🚀 Starting Sample Menu Seeder...\n\n";

        // Sample menu items to demonstrate the system
        $sampleMenus = [
            // Master Data menus
            [
                'KODEMENU' => 'MASTER_CUSTOMER',
                'Keterangan' => 'Master Customer',
                'L0' => '01',
                'OL' => 10,
                'icon' => 'fas fa-users',
                'routename' => 'master/customer',
                'TipeTrans' => 'MASTER'
            ],
            [
                'KODEMENU' => 'MASTER_SUPPLIER',
                'Keterangan' => 'Master Supplier',
                'L0' => '01',
                'OL' => 20,
                'icon' => 'fas fa-truck',
                'routename' => 'master/supplier',
                'TipeTrans' => 'MASTER'
            ],
            [
                'KODEMENU' => 'MASTER_PRODUCT',
                'Keterangan' => 'Master Product',
                'L0' => '01',
                'OL' => 30,
                'icon' => 'fas fa-box',
                'routename' => 'master/product',
                'TipeTrans' => 'MASTER'
            ],

            // Accounting menus
            [
                'KODEMENU' => 'JURNAL_UMUM',
                'Keterangan' => 'Jurnal Umum',
                'L0' => '02',
                'OL' => 10,
                'icon' => 'fas fa-book',
                'routename' => 'accounting/journal',
                'TipeTrans' => 'TRANS'
            ],
            [
                'KODEMENU' => 'BUKU_BESAR',
                'Keterangan' => 'Buku Besar',
                'L0' => '02',
                'OL' => 20,
                'icon' => 'fas fa-book-open',
                'routename' => 'accounting/ledger',
                'TipeTrans' => 'REPORT'
            ],

            // Marketing menus
            [
                'KODEMENU' => 'SALES_ORDER',
                'Keterangan' => 'Sales Order',
                'L0' => '05',
                'OL' => 10,
                'icon' => 'fas fa-handshake',
                'routename' => 'marketing/sales-order',
                'TipeTrans' => 'TRANS'
            ],
            [
                'KODEMENU' => 'DELIVERY_ORDER',
                'Keterangan' => 'Delivery Order',
                'L0' => '05',
                'OL' => 20,
                'icon' => 'fas fa-shipping-fast',
                'routename' => 'marketing/delivery-order',
                'TipeTrans' => 'TRANS'
            ],

            // Reports
            [
                'KODEMENU' => 'LAP_PENJUALAN',
                'Keterangan' => 'Laporan Penjualan',
                'L0' => '08',
                'OL' => 10,
                'icon' => 'fas fa-chart-area',
                'routename' => 'reports/sales',
                'TipeTrans' => 'REPORT'
            ],
            [
                'KODEMENU' => 'LAP_KEUANGAN',
                'Keterangan' => 'Laporan Keuangan',
                'L0' => '08',
                'OL' => 20,
                'icon' => 'fas fa-money-check-alt',
                'routename' => 'reports/financial',
                'TipeTrans' => 'REPORT'
            ],

            // Utilities
            [
                'KODEMENU' => 'BACKUP_RESTORE',
                'Keterangan' => 'Backup & Restore',
                'L0' => '081',
                'OL' => 20,
                'icon' => 'fas fa-download',
                'routename' => 'utilities/backup',
                'TipeTrans' => 'UTIL'
            ],
            [
                'KODEMENU' => 'SYSTEM_SETTINGS',
                'Keterangan' => 'System Settings',
                'L0' => '081',
                'OL' => 30,
                'icon' => 'fas fa-cog',
                'routename' => 'utilities/settings',
                'TipeTrans' => 'UTIL'
            ]
        ];

        foreach ($sampleMenus as $menuData) {
            // Check if menu already exists
            $existingMenu = DbMENU::where('KODEMENU', $menuData['KODEMENU'])->first();

            if (!$existingMenu) {
                // Create menu
                $menu = DbMENU::create([
                    'KODEMENU' => $menuData['KODEMENU'],
                    'Keterangan' => $menuData['Keterangan'],
                    'L0' => $menuData['L0'],
                    'ACCESS' => 1,
                    'OL' => $menuData['OL'],
                    'TipeTrans' => $menuData['TipeTrans'],
                    'icon' => $menuData['icon'],
                    'routename' => $menuData['routename']
                ]);

                echo "✅ Menu '{$menuData['Keterangan']}' created\n";

                // Assign permissions based on menu type
                $this->assignDefaultPermissions($menu);

            } else {
                echo "ℹ️  Menu '{$menuData['Keterangan']}' already exists, skipping...\n";
            }
        }

        echo "\n🎉 Sample Menu Seeder completed!\n";
        echo "📋 Use these sample menus to test the dynamic menu system.\n";
        echo "💡 You can add more menus via API endpoints without touching the code.\n\n";
    }

    /**
     * Assign default permissions based on menu type and user level
     */
    private function assignDefaultPermissions($menu)
    {
        $users = DbFLPASS::all();

        foreach ($users as $user) {
            $permissions = $this->getDefaultPermissionsByMenuType($menu->TipeTrans, $user->TINGKAT);

            // Check if permission already exists
            $existingPermission = DbFLMENU::where('USERID', $user->USERID)
                ->where('L1', $menu->KODEMENU)
                ->first();

            if (!$existingPermission) {
                DbFLMENU::create([
                    'USERID' => $user->USERID,
                    'L1' => $menu->KODEMENU,
                    'HASACCESS' => $permissions['access'] ? 1 : 0,
                    'ISTAMBAH' => $permissions['add'] ? 1 : 0,
                    'ISKOREKSI' => $permissions['edit'] ? 1 : 0,
                    'ISHAPUS' => $permissions['delete'] ? 1 : 0,
                    'ISCETAK' => $permissions['print'] ? 1 : 0,
                    'ISEXPORT' => $permissions['export'] ? 1 : 0,
                    'TIPE' => substr($menu->TipeTrans ?? 'MENU', 0, 10) // Limit to 10 chars
                ]);
            }
        }
    }

    /**
     * Get default permissions based on menu type and user level
     */
    private function getDefaultPermissionsByMenuType($menuType, $userLevel)
    {
        // Default permissions structure
        $permissions = [
            'access' => false,
            'add' => false,
            'edit' => false,
            'delete' => false,
            'print' => false,
            'export' => false
        ];

        // Admin users (level 4+) get full access to everything
        if ($userLevel >= 4) {
            return [
                'access' => true,
                'add' => true,
                'edit' => true,
                'delete' => true,
                'print' => true,
                'export' => true
            ];
        }

        // Manager users (level 3) get limited access
        if ($userLevel >= 3) {
            switch ($menuType) {
                case 'MASTER':
                case 'TRANSAKSI':
                    return [
                        'access' => true,
                        'add' => true,
                        'edit' => true,
                        'delete' => false, // No delete for managers
                        'print' => true,
                        'export' => true
                    ];
                case 'LAPORAN':
                    return [
                        'access' => true,
                        'add' => false,
                        'edit' => false,
                        'delete' => false,
                        'print' => true,
                        'export' => true
                    ];
                case 'UTILITY':
                case 'ADMIN':
                    return [
                        'access' => false, // No utility access for managers
                        'add' => false,
                        'edit' => false,
                        'delete' => false,
                        'print' => false,
                        'export' => false
                    ];
            }
        }

        // Regular users (level 1-2) get read-only access
        if ($userLevel >= 1) {
            switch ($menuType) {
                case 'MASTER':
                case 'TRANSAKSI':
                    return [
                        'access' => true,
                        'add' => false,
                        'edit' => false,
                        'delete' => false,
                        'print' => true,
                        'export' => false
                    ];
                case 'LAPORAN':
                    return [
                        'access' => true,
                        'add' => false,
                        'edit' => false,
                        'delete' => false,
                        'print' => true,
                        'export' => false
                    ];
                case 'UTILITY':
                case 'ADMIN':
                    return [
                        'access' => false, // No admin access for regular users
                        'add' => false,
                        'edit' => false,
                        'delete' => false,
                        'print' => false,
                        'export' => false
                    ];
            }
        }

        return $permissions;
    }
}