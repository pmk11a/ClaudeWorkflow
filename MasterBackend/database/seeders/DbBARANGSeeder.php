<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\DbBARANG;

class DbBARANGSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Buat 50 barang sample menggunakan factory
        DbBARANG::factory(50)->create();
        
        // Buat 10 barang elektronik
        DbBARANG::factory(10)->elektronik()->create();
        
        // Buat 5 spare part mahal
        DbBARANG::factory(5)->sparePart()->expensive()->create();
        
        // Buat beberapa barang manual untuk testing
        $manualItems = [
            [
                'KODEBRG' => 'TEST001',
                'NAMABRG' => 'Test Item 1',
                'KODEKTG' => 'TEST',
                'KODEKEL' => 'A',
                'SATUAN' => 'PCS',
                'HARGABELI' => 10000.00,
                'HARGAJUAL' => 15000.00,
                'STOKMIN' => 10,
                'STOKMAX' => 100,
                'ISAKTIF' => true,
                'KETERANGAN' => 'Barang untuk testing aplikasi'
            ],
            [
                'KODEBRG' => 'TEST002',
                'NAMABRG' => 'Test Item 2',
                'KODEKTG' => 'TEST',
                'KODEKEL' => 'B',
                'SATUAN' => 'SET',
                'HARGABELI' => 50000.00,
                'HARGAJUAL' => 75000.00,
                'STOKMIN' => 5,
                'STOKMAX' => 50,
                'ISAKTIF' => true,
                'KETERANGAN' => 'Barang set untuk testing'
            ],
            [
                'KODEBRG' => 'DEMO001',
                'NAMABRG' => 'Demo Product',
                'KODEKTG' => 'DEMO',
                'KODEKEL' => 'C',
                'SATUAN' => 'KG',
                'HARGABELI' => 25000.00,
                'HARGAJUAL' => 35000.00,
                'STOKMIN' => 20,
                'STOKMAX' => 200,
                'ISAKTIF' => true,
                'KETERANGAN' => 'Produk untuk demo aplikasi'
            ]
        ];
        
        foreach ($manualItems as $item) {
            DbBARANG::create($item);
        }
        
        $this->command->info('✅ Created sample items:');
        $this->command->info('   - 50 random items');
        $this->command->info('   - 10 electronic items');
        $this->command->info('   - 5 expensive spare parts');
        $this->command->info('   - 3 manual test items');
        $this->command->info('   Total: ' . DbBARANG::count() . ' items');
    }
}
