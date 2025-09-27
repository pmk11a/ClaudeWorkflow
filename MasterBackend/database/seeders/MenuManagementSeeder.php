<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\DbMENU;
use App\Models\DbFLMENU;
use App\Models\DbFLPASS;
use Illuminate\Support\Facades\DB;

class MenuManagementSeeder extends Seeder
{
    /**
     * Seed menu management entries
     */
    public function run()
    {
        // Check if MENU_MANAGEMENT already exists
        $existingMenu = DbMENU::where('KODEMENU', 'MENU_MANAGEMENT')->first();

        if (!$existingMenu) {
            // Create Menu Management menu entry
            DbMENU::create([
                'KODEMENU' => 'MENU_MANAGEMENT',
                'Keterangan' => 'Menu Management',
                'L0' => '081',  // Assuming this goes under SYSTEM/UTILITAS group
                'ACCESS' => 1,
                'OL' => 10,
                'TipeTrans' => 'ADMIN',
                'icon' => 'fas fa-sitemap',
                'routename' => 'menu-management'
            ]);

            echo "✅ Menu Management entry created in DBMENU\n";

            // Give access to admin users (level 4 and above)
            $adminUsers = DbFLPASS::where('TINGKAT', '>=', 4)->get();

            foreach ($adminUsers as $admin) {
                // Check if permission already exists
                $existingPermission = DbFLMENU::where('USERID', $admin->USERID)
                    ->where('L1', 'MENU_MANAGEMENT')
                    ->first();

                if (!$existingPermission) {
                    DbFLMENU::create([
                        'USERID' => $admin->USERID,
                        'L1' => 'MENU_MANAGEMENT',
                        'HASACCESS' => 1,
                        'ISTAMBAH' => 1,
                        'ISKOREKSI' => 1,
                        'ISHAPUS' => 1,
                        'ISCETAK' => 1,
                        'ISEXPORT' => 1,
                        'TIPE' => 'ADMIN'
                    ]);
                }
            }

            echo "✅ Menu Management permissions granted to " . $adminUsers->count() . " admin users\n";
        } else {
            echo "ℹ️  Menu Management already exists, skipping...\n";
        }

        // Ensure required group headers exist
        $this->ensureGroupHeaders();
    }

    /**
     * Ensure required group headers exist
     */
    private function ensureGroupHeaders()
    {
        $groupHeaders = [
            ['KODEMENU' => '01', 'Keterangan' => 'MASTER DATA', 'icon' => 'fas fa-database'],
            ['KODEMENU' => '02', 'Keterangan' => 'ACCOUNTING', 'icon' => 'fas fa-calculator'],
            ['KODEMENU' => '03', 'Keterangan' => 'BERKAS', 'icon' => 'fas fa-folder-open'],
            ['KODEMENU' => '04', 'Keterangan' => 'PENGADAAN', 'icon' => 'fas fa-shopping-cart'],
            ['KODEMENU' => '05', 'Keterangan' => 'MARKETING', 'icon' => 'fas fa-bullhorn'],
            ['KODEMENU' => '06', 'Keterangan' => 'PRODUKSI', 'icon' => 'fas fa-industry'],
            ['KODEMENU' => '07', 'Keterangan' => 'GUDANG', 'icon' => 'fas fa-warehouse'],
            ['KODEMENU' => '08', 'Keterangan' => 'LAPORAN', 'icon' => 'fas fa-chart-bar'],
            ['KODEMENU' => '081', 'Keterangan' => 'UTILITAS', 'icon' => 'fas fa-tools'],
            ['KODEMENU' => '09', 'Keterangan' => 'JENDELA', 'icon' => 'fas fa-window-maximize']
        ];

        foreach ($groupHeaders as $header) {
            $existing = DbMENU::where('KODEMENU', $header['KODEMENU'])->first();

            if (!$existing) {
                DbMENU::create([
                    'KODEMENU' => $header['KODEMENU'],
                    'Keterangan' => $header['Keterangan'],
                    'L0' => '0',  // Group headers have L0 = '0'
                    'ACCESS' => 1,
                    'OL' => 0,
                    'TipeTrans' => 'GROUP',
                    'icon' => $header['icon'],
                    'routename' => null
                ]);

                echo "✅ Group header '{$header['Keterangan']}' created\n";
            }
        }
    }
}