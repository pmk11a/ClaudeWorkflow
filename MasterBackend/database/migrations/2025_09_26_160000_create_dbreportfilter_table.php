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
        Schema::create('DBREPORTFILTER', function (Blueprint $table) {
            $table->id('ID');
            $table->string('KODEREPORT', 20)->index('idx_dbreportfilter_kodereport');
            $table->string('FILTER_NAME', 100);
            $table->string('FILTER_TYPE', 50); // 'date', 'daterange', 'select', 'text', 'checkbox', 'radio', 'lookup'
            $table->string('FIELD_NAME', 100);
            $table->string('LABEL', 255)->nullable();
            $table->text('DEFAULT_VALUE')->nullable();
            $table->text('OPTIONS_SOURCE')->nullable(); // JSON config for options or table/view name
            $table->boolean('IS_REQUIRED')->default(false);
            $table->integer('SORT_ORDER');
            $table->boolean('IS_VISIBLE')->default(true);
            $table->text('VALIDATION_RULES')->nullable(); // JSON validation rules
            $table->text('FILTER_CONFIG')->nullable(); // Additional JSON configuration
            $table->timestamp('CREATED_DATE')->useCurrent();
            $table->timestamp('MODIFIED_DATE')->useCurrent()->useCurrentOnUpdate();

            // Composite index for report filters
            $table->index(['KODEREPORT', 'IS_VISIBLE', 'SORT_ORDER'], 'idx_report_active_filters');

            // Foreign key reference (if DBREPORTCONFIG exists)
            // $table->foreign('KODEREPORT')->references('KODEREPORT')->on('DBREPORTCONFIG');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('DBREPORTFILTER');
    }
};