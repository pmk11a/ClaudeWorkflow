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
        // Create exact replica of DBBARANG table structure from SQL Server
        Schema::create('dbbarang_backup', function (Blueprint $table) {
            // Primary Key
            $table->string('KODEBRG', 20)->primary();
            
            // Basic Item Information
            $table->string('NAMABRG', 100)->nullable();
            $table->string('KODEKTG', 10)->nullable();
            $table->string('KODEKEL', 10)->nullable();
            $table->string('SATUAN', 10)->nullable();
            
            // Pricing
            $table->decimal('HARGABELI', 15, 2)->nullable()->default(0);
            $table->decimal('HARGAJUAL', 15, 2)->nullable()->default(0);
            
            // Stock Management
            $table->decimal('QTY', 15, 2)->nullable()->default(0);
            $table->integer('STOKMIN')->nullable()->default(0);
            $table->integer('STOKMAX')->nullable()->default(0);
            
            // Product Details
            $table->string('MERK', 50)->nullable();
            $table->string('MODEL', 50)->nullable();
            $table->text('SPESIFIKASI')->nullable();
            $table->text('KETERANGAN')->nullable();
            
            // Status Flags
            $table->boolean('ISAKTIF')->default(true);
            $table->boolean('NFix')->default(false);
            $table->boolean('IsTakeIn')->default(false);
            $table->boolean('IsBarang')->default(true);
            $table->boolean('IsJasa')->default(false);
            
            // Additional fields that might exist in your database
            $table->string('KODEJNS', 10)->nullable();
            $table->string('KODEMRK', 10)->nullable();
            $table->string('KODEGRP', 10)->nullable();
            $table->decimal('DISC', 5, 2)->nullable()->default(0);
            $table->decimal('PPN', 5, 2)->nullable()->default(0);
            
            // Laravel standard timestamps
            $table->timestamps();
            
            // Indexes for better performance
            $table->index(['KODEKTG'], 'idx_dbbarang_kategori');
            $table->index(['KODEKEL'], 'idx_dbbarang_kelompok');
            $table->index(['ISAKTIF'], 'idx_dbbarang_active');
            $table->index(['QTY'], 'idx_dbbarang_qty');
            $table->index(['HARGAJUAL'], 'idx_dbbarang_price');
            
            // Foreign key constraints (if needed)
            // $table->foreign('KODEKTG')->references('KODEKTG')->on('DBKATEGORI');
            // $table->foreign('KODEKEL')->references('KODEKEL')->on('DBKELOMPOK');
        });
        
        // SQL Server doesn't support COMMENT ON TABLE syntax
        // Table comment: 'Backup table for DBBARANG - Laravel migration generated schema'
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('dbbarang_backup');
    }
};
