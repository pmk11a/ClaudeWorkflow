<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('DBREPORTFILTER', function (Blueprint $table) {
            // Add missing columns if they don't exist
            if (!Schema::hasColumn('DBREPORTFILTER', 'FILTER_TYPE')) {
                $table->string('FILTER_TYPE', 50)->after('FILTER_NAME'); // 'date', 'daterange', 'select', 'text', 'checkbox', 'radio', 'lookup'
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'LABEL')) {
                $table->string('LABEL', 255)->nullable()->after('FIELD_NAME');
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'DEFAULT_VALUE')) {
                $table->text('DEFAULT_VALUE')->nullable()->after('LABEL');
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'OPTIONS_SOURCE')) {
                $table->text('OPTIONS_SOURCE')->nullable()->after('DEFAULT_VALUE'); // JSON config for options or table/view name
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'IS_REQUIRED')) {
                $table->boolean('IS_REQUIRED')->default(false)->after('OPTIONS_SOURCE');
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'SORT_ORDER')) {
                $table->integer('SORT_ORDER')->after('IS_REQUIRED');
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'IS_VISIBLE')) {
                $table->boolean('IS_VISIBLE')->default(true)->after('SORT_ORDER');
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'VALIDATION_RULES')) {
                $table->text('VALIDATION_RULES')->nullable()->after('IS_VISIBLE'); // JSON validation rules
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'FILTER_CONFIG')) {
                $table->text('FILTER_CONFIG')->nullable()->after('VALIDATION_RULES'); // Additional JSON configuration
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'CREATED_DATE')) {
                $table->timestamp('CREATED_DATE')->useCurrent()->after('FILTER_CONFIG');
            }

            if (!Schema::hasColumn('DBREPORTFILTER', 'MODIFIED_DATE')) {
                $table->timestamp('MODIFIED_DATE')->useCurrent()->useCurrentOnUpdate()->after('CREATED_DATE');
            }
        });

        // Add indexes if they don't exist
        try {
            Schema::table('DBREPORTFILTER', function (Blueprint $table) {
                $table->index('KODEREPORT', 'idx_dbreportfilter_kodereport');
            });
        } catch (Exception $e) {
            // Index might already exist
        }

        try {
            Schema::table('DBREPORTFILTER', function (Blueprint $table) {
                $table->index(['KODEREPORT', 'IS_VISIBLE', 'SORT_ORDER'], 'idx_report_active_filters');
            });
        } catch (Exception $e) {
            // Index might already exist
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('DBREPORTFILTER', function (Blueprint $table) {
            // Remove added columns in reverse order
            $columnsToRemove = [
                'MODIFIED_DATE', 'CREATED_DATE', 'FILTER_CONFIG', 'VALIDATION_RULES',
                'IS_VISIBLE', 'SORT_ORDER', 'IS_REQUIRED', 'OPTIONS_SOURCE',
                'DEFAULT_VALUE', 'LABEL', 'FILTER_TYPE'
            ];

            foreach ($columnsToRemove as $column) {
                if (Schema::hasColumn('DBREPORTFILTER', $column)) {
                    $table->dropColumn($column);
                }
            }
        });

        // Drop indexes
        try {
            Schema::table('DBREPORTFILTER', function (Blueprint $table) {
                $table->dropIndex('idx_dbreportfilter_kodereport');
                $table->dropIndex('idx_report_active_filters');
            });
        } catch (Exception $e) {
            // Indexes might not exist
        }
    }
};