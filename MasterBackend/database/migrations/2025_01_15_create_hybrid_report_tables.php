bu<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for hybrid report system.
     */
    public function up(): void
    {
        // 1. Report Configuration Table (Hybrid approach)
        Schema::create('DBREPORTCONFIG', function (Blueprint $table) {
            $table->id('ID');
            $table->string('KODEREPORT', 50)->comment('Link to DBMENUREPORT.ACCESS');
            $table->enum('CONFIG_TYPE', ['FRONTEND', 'BACKEND', 'SHARED'])->comment('Configuration type');
            $table->string('STOREDPROC', 200)->nullable()->comment('Stored procedure name');
            $table->text('CONFIG_JSON')->nullable()->comment('Mode-specific settings');
            $table->boolean('IS_ACTIVE')->default(1)->comment('Active status');
            $table->timestamp('CREATED_AT')->useCurrent();
            $table->timestamp('UPDATED_AT')->useCurrent()->useCurrentOnUpdate();

            $table->index(['KODEREPORT', 'CONFIG_TYPE'], 'IX_REPORTCONFIG_CODE_TYPE');
            $table->index('IS_ACTIVE', 'IX_REPORTCONFIG_ACTIVE');
        });

        // 2. Report Header Configuration (Separate for performance)
        Schema::create('DBREPORTHEADER', function (Blueprint $table) {
            $table->id('ID');
            $table->string('KODEREPORT', 50)->comment('Link to DBMENUREPORT.ACCESS');
            $table->string('TITLE', 200)->nullable()->comment('Report title');
            $table->string('SUBTITLE', 200)->nullable()->comment('Report subtitle');
            $table->boolean('SHOW_DATE')->default(1)->comment('Show generation date');
            $table->boolean('SHOW_PARAMS')->default(1)->comment('Show parameters used');
            $table->boolean('SHOW_LOGO')->default(0)->comment('Show company logo');
            $table->string('ORIENTATION', 20)->default('PORTRAIT')->comment('Page orientation');
            $table->string('PAGE_SIZE', 20)->default('A4')->comment('Page size');
            $table->boolean('IS_ACTIVE')->default(1)->comment('Active status');
            $table->timestamp('CREATED_AT')->useCurrent();
            $table->timestamp('UPDATED_AT')->useCurrent()->useCurrentOnUpdate();

            $table->index('KODEREPORT', 'IX_REPORTHEADER_CODE');
            $table->index('IS_ACTIVE', 'IX_REPORTHEADER_ACTIVE');
        });

        // 3. Report Column Configuration (Separate for performance)
        Schema::create('DBREPORTCOLUMN', function (Blueprint $table) {
            $table->id('ID');
            $table->string('KODEREPORT', 50)->comment('Link to DBMENUREPORT.ACCESS');
            $table->string('COLUMN_NAME', 100)->comment('Field name from stored procedure');
            $table->string('COLUMN_LABEL', 200)->comment('Display label');
            $table->integer('WIDTH')->default(100)->comment('Column width in pixels');
            $table->enum('ALIGNMENT', ['LEFT', 'CENTER', 'RIGHT'])->default('LEFT')->comment('Text alignment');
            $table->string('DATA_TYPE', 50)->default('TEXT')->comment('Data type for formatting');
            $table->string('FORMAT_MASK', 100)->nullable()->comment('Format mask (currency, date, etc)');
            $table->integer('SORT_ORDER')->default(0)->comment('Display order');
            $table->boolean('IS_VISIBLE')->default(1)->comment('Show/hide column');
            $table->boolean('IS_ACTIVE')->default(1)->comment('Active status');
            $table->timestamp('CREATED_AT')->useCurrent();
            $table->timestamp('UPDATED_AT')->useCurrent()->useCurrentOnUpdate();

            $table->index(['KODEREPORT', 'SORT_ORDER'], 'IX_REPORTCOLUMN_CODE_ORDER');
            $table->index(['KODEREPORT', 'IS_VISIBLE'], 'IX_REPORTCOLUMN_CODE_VISIBLE');
            $table->index('IS_ACTIVE', 'IX_REPORTCOLUMN_ACTIVE');
        });

        // 4. Report Group Configuration (Separate for performance)
        Schema::create('DBREPORTGROUP', function (Blueprint $table) {
            $table->id('ID');
            $table->string('KODEREPORT', 50)->comment('Link to DBMENUREPORT.ACCESS');
            $table->string('GROUP_FIELD', 100)->comment('Field to group by');
            $table->string('GROUP_LABEL', 200)->nullable()->comment('Group display label');
            $table->boolean('SHOW_HEADER')->default(1)->comment('Show group header');
            $table->boolean('SHOW_FOOTER')->default(1)->comment('Show group footer');
            $table->boolean('SHOW_SUM')->default(0)->comment('Show group totals');
            $table->text('SUM_FIELDS')->nullable()->comment('Fields to sum (JSON array)');
            $table->boolean('PAGE_BREAK')->default(0)->comment('Page break after group');
            $table->integer('SORT_ORDER')->default(0)->comment('Group level order');
            $table->boolean('IS_ACTIVE')->default(1)->comment('Active status');
            $table->timestamp('CREATED_AT')->useCurrent();
            $table->timestamp('UPDATED_AT')->useCurrent()->useCurrentOnUpdate();

            $table->index(['KODEREPORT', 'SORT_ORDER'], 'IX_REPORTGROUP_CODE_ORDER');
            $table->index('IS_ACTIVE', 'IX_REPORTGROUP_ACTIVE');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('DBREPORTGROUP');
        Schema::dropIfExists('DBREPORTCOLUMN');
        Schema::dropIfExists('DBREPORTHEADER');
        Schema::dropIfExists('DBREPORTCONFIG');
    }
};