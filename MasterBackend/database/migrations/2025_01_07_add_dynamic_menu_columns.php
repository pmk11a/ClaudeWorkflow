<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for adding dynamic menu columns.
     */
    public function up(): void
    {
        Schema::table('DBMENU', function (Blueprint $table) {
            // Add columns only if they don't exist
            if (!Schema::hasColumn('DBMENU', 'icon')) {
                $table->string('icon', 100)->nullable()->after('TipeTrans')->comment('Menu icon class (e.g., fas fa-users)');
            }
            
            if (!Schema::hasColumn('DBMENU', 'routename')) {
                $table->string('routename', 200)->nullable()->after('icon')->comment('Laravel route name or URL');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('DBMENU', function (Blueprint $table) {
            if (Schema::hasColumn('DBMENU', 'icon')) {
                $table->dropColumn('icon');
            }
            
            if (Schema::hasColumn('DBMENU', 'routename')) {
                $table->dropColumn('routename');
            }
        });
    }
};