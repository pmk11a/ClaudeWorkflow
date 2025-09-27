<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\DbBARANG>
 */
class DbBARANGFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition()
    {
        $categories = ['ELEC', 'MECH', 'CHEM', 'TOOL', 'SPAR'];
        $groups = ['A', 'B', 'C', 'D', 'E'];
        $units = ['PCS', 'KG', 'LTR', 'MTR', 'SET'];
        
        return [
            'KODEBRG' => strtoupper($this->faker->unique()->bothify('??###')),
            'NAMABRG' => $this->faker->words(3, true),
            'KODEKTG' => $this->faker->randomElement($categories),
            'KODEKEL' => $this->faker->randomElement($groups),
            'SATUAN' => $this->faker->randomElement($units),
            'HARGABELI' => $this->faker->randomFloat(2, 1000, 100000),
            'HARGAJUAL' => $this->faker->randomFloat(2, 1500, 150000),
            'STOKMIN' => $this->faker->numberBetween(5, 50),
            'STOKMAX' => $this->faker->numberBetween(100, 1000),
            'ISAKTIF' => $this->faker->boolean(90), // 90% aktif
            'KETERANGAN' => $this->faker->optional(0.7)->sentence(),
            'MERK' => $this->faker->optional(0.8)->company(),
            'MODEL' => $this->faker->optional(0.6)->bothify('MOD-####'),
            'SPESIFIKASI' => $this->faker->optional(0.5)->text(100),
        ];
    }
    
    // State untuk barang elektronik
    public function elektronik()
    {
        return $this->state(function (array $attributes) {
            return [
                'KODEKTG' => 'ELEC',
                'NAMABRG' => $this->faker->randomElement([
                    'Resistor', 'Capacitor', 'Transistor', 'IC', 'Relay', 'Sensor'
                ]) . ' ' . $this->faker->bothify('###-??'),
                'SATUAN' => 'PCS',
                'MERK' => $this->faker->randomElement(['OMRON', 'SCHNEIDER', 'ABB', 'SIEMENS']),
            ];
        });
    }
    
    // State untuk spare part
    public function sparePart()
    {
        return $this->state(function (array $attributes) {
            return [
                'KODEKTG' => 'SPAR',
                'NAMABRG' => 'Spare Part ' . $this->faker->words(2, true),
                'SATUAN' => $this->faker->randomElement(['PCS', 'SET']),
                'HARGABELI' => $this->faker->randomFloat(2, 5000, 500000),
                'HARGAJUAL' => $this->faker->randomFloat(2, 7500, 750000),
            ];
        });
    }
    
    // State untuk barang mahal
    public function expensive()
    {
        return $this->state(function (array $attributes) {
            return [
                'HARGABELI' => $this->faker->randomFloat(2, 100000, 10000000),
                'HARGAJUAL' => $this->faker->randomFloat(2, 150000, 15000000),
                'STOKMIN' => $this->faker->numberBetween(1, 5),
                'STOKMAX' => $this->faker->numberBetween(10, 50),
            ];
        });
    }
}
