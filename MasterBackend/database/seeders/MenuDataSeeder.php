<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MenuDataSeeder extends Seeder
{
    /**
     * Run the database seeds for menu data with dynamic icons and routes.
     */
    public function run(): void
    {
        // Sample menu data with dynamic icon and routename
        $menus = [
            // GROUP DEFINITIONS (L0 = '0')
            [
                'KODEMENU' => 'DASHBOARD',
                'Keterangan' => 'Dashboard',
                'L0' => '0',
                'ACCESS' => 1,
                'OL' => 0,
                'icon' => 'fas fa-tachometer-alt',
                'routename' => null
            ],
            [
                'KODEMENU' => 'MASTER DATA',
                'Keterangan' => 'Master Data',
                'L0' => '0',
                'ACCESS' => 1,
                'OL' => 1,
                'icon' => 'fas fa-database',
                'routename' => null
            ],
            [
                'KODEMENU' => 'ACCOUNTING',
                'Keterangan' => 'Accounting',
                'L0' => '0',
                'ACCESS' => 1,
                'OL' => 2,
                'icon' => 'fas fa-calculator',
                'routename' => null
            ],
            [
                'KODEMENU' => 'BERKAS',
                'Keterangan' => 'Berkas',
                'L0' => '0',
                'ACCESS' => 1,
                'OL' => 3,
                'icon' => 'fas fa-folder-open',
                'routename' => null
            ],
            [
                'KODEMENU' => 'LAPORAN',
                'Keterangan' => 'Laporan',
                'L0' => '0',
                'ACCESS' => 1,
                'OL' => 4,
                'icon' => 'fas fa-chart-bar',
                'routename' => null
            ],
            [
                'KODEMENU' => 'SYSTEM',
                'Keterangan' => 'System',
                'L0' => '0',
                'ACCESS' => 1,
                'OL' => 5,
                'icon' => 'fas fa-cogs',
                'routename' => null
            ],
            
            // MENU ITEMS
            [
                'KODEMENU' => 'DASHBOARD_MAIN',
                'Keterangan' => 'Dashboard',
                'L0' => 'DASHBOARD',
                'ACCESS' => 1,
                'OL' => 1,
                'icon' => 'fas fa-tachometer-alt',
                'routename' => 'dashboard'
            ],
            
            // Master Data
            [
                'KODEMENU' => 'MASTER_CUSTOMER',
                'Keterangan' => 'Data Customer',
                'L0' => 'MASTER DATA',
                'ACCESS' => 1,
                'OL' => 2,
                'icon' => 'fas fa-users',
                'routename' => 'customers.index'
            ],
            [
                'KODEMENU' => 'MASTER_SUPPLIER',
                'Keterangan' => 'Data Supplier',
                'L0' => 'MASTER DATA',
                'ACCESS' => 1,
                'OL' => 3,
                'icon' => 'fas fa-truck',
                'routename' => 'suppliers.index'
            ],
            [
                'KODEMENU' => 'MASTER_BARANG',
                'Keterangan' => 'Data Barang',
                'L0' => 'MASTER DATA',
                'ACCESS' => 1,
                'OL' => 4,
                'icon' => 'fas fa-boxes',
                'routename' => 'products.index'
            ],
            
            // Accounting
            [
                'KODEMENU' => 'JURNAL_UMUM',
                'Keterangan' => 'Jurnal Umum',
                'L0' => 'ACCOUNTING',
                'ACCESS' => 1,
                'OL' => 5,
                'icon' => 'fas fa-book',
                'routename' => 'journals.general'
            ],
            [
                'KODEMENU' => 'BUKU_BESAR',
                'Keterangan' => 'Buku Besar',
                'L0' => 'ACCOUNTING',
                'ACCESS' => 1,
                'OL' => 6,
                'icon' => 'fas fa-book-open',
                'routename' => 'ledgers.general'
            ],
            [
                'KODEMENU' => 'NERACA',
                'Keterangan' => 'Laporan Neraca',
                'L0' => 'ACCOUNTING',
                'ACCESS' => 1,
                'OL' => 7,
                'icon' => 'fas fa-balance-scale',
                'routename' => 'reports.balance'
            ],
            
            // Berkas
            [
                'KODEMENU' => 'BERKAS_MASUK',
                'Keterangan' => 'Berkas Masuk',
                'L0' => 'BERKAS',
                'ACCESS' => 1,
                'OL' => 8,
                'icon' => 'fas fa-inbox',
                'routename' => 'documents.incoming'
            ],
            [
                'KODEMENU' => 'BERKAS_KELUAR',
                'Keterangan' => 'Berkas Keluar',
                'L0' => 'BERKAS',
                'ACCESS' => 1,
                'OL' => 9,
                'icon' => 'fas fa-paper-plane',
                'routename' => 'documents.outgoing'
            ],
            
            // Laporan
            [
                'KODEMENU' => 'LAP_PENJUALAN',
                'Keterangan' => 'Laporan Penjualan',
                'L0' => 'LAPORAN',
                'ACCESS' => 1,
                'OL' => 10,
                'icon' => 'fas fa-chart-area',
                'routename' => 'reports.sales'
            ],
            [
                'KODEMENU' => 'LAP_PEMBELIAN',
                'Keterangan' => 'Laporan Pembelian',
                'L0' => 'LAPORAN',
                'ACCESS' => 1,
                'OL' => 11,
                'icon' => 'fas fa-chart-bar',
                'routename' => 'reports.purchases'
            ],
            
            // System
            [
                'KODEMENU' => 'USER_MGMT',
                'Keterangan' => 'User Management',
                'L0' => 'SYSTEM',
                'ACCESS' => 1,
                'OL' => 12,
                'icon' => 'fas fa-users-cog',
                'routename' => 'users.index'
            ],
            [
                'KODEMENU' => 'USER_PERMISSION',
                'Keterangan' => 'User Permissions',
                'L0' => 'SYSTEM',
                'ACCESS' => 1,
                'OL' => 13,
                'icon' => 'fas fa-user-shield',
                'routename' => 'permissions.index'
            ],
        ];
        
        // Insert or update menu data
        foreach ($menus as $menu) {
            DB::table('DBMENU')->updateOrInsert(
                ['KODEMENU' => $menu['KODEMENU']], // Where condition
                $menu // Values to insert/update
            );
        }
        
        $this->command->info('Menu data seeded successfully with dynamic icons and routes!');
    }
}