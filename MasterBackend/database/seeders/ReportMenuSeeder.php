<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ReportMenuSeeder extends Seeder
{
    /**
     * Run the database seeds for report menu items.
     */
    public function run(): void
    {
        // Insert menu items for report system
        $this->insertReportMenus();
        $this->insertUserPermissions();
    }

    private function insertReportMenus(): void
    {
        // Check if menu items already exist
        $existingGroup = DB::select("SELECT KODEMENU FROM DBMENU WHERE KODEMENU = '9000'");
        $existingMenu = DB::select("SELECT KODEMENU FROM DBMENU WHERE KODEMENU = '9001'");

        // Insert group menu "Laporan-laporan" if not exists
        if (empty($existingGroup)) {
            DB::insert("
                INSERT INTO DBMENU (KODEMENU, Keterangan, L0, ACCESS)
                VALUES (?, ?, ?, ?)
            ", ['9000', 'Laporan-laporan', 0, 1]);

            echo "✅ Inserted group menu: Laporan-laporan (9000)\n";
        } else {
            echo "ℹ️ Group menu already exists: Laporan-laporan (9000)\n";
        }

        // Insert submenu "Laporan" if not exists
        if (empty($existingMenu)) {
            DB::insert("
                INSERT INTO DBMENU (KODEMENU, Keterangan, L0, ACCESS)
                VALUES (?, ?, ?, ?)
            ", ['9001', 'Laporan', 1, 1]);

            echo "✅ Inserted submenu: Laporan (9001)\n";
        } else {
            echo "ℹ️ Submenu already exists: Laporan (9001)\n";
        }
    }

    private function insertUserPermissions(): void
    {
        // Users to grant report access
        $users = ['ADMIN', 'SA'];

        foreach ($users as $userId) {
            // Check if permission already exists
            $existing = DB::select("
                SELECT USERID FROM DBFLMENU
                WHERE USERID = ? AND L1 = ?
            ", [$userId, '9001']);

            if (empty($existing)) {
                DB::insert("
                    INSERT INTO DBFLMENU (USERID, L1, HASACCESS, ISTAMBAH, ISKOREKSI, ISHAPUS, ISCETAK, ISEXPORT, TIPE)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ", [$userId, '9001', 1, 0, 0, 0, 1, 1, 'MENU']);

                echo "✅ Added report permissions for user: {$userId}\n";
            } else {
                echo "ℹ️ Report permissions already exist for user: {$userId}\n";
            }
        }
    }
}