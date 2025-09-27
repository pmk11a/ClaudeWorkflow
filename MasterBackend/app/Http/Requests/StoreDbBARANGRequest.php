<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreDbBARANGRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        // Authorize if user is authenticated (sesuaikan dengan sistem auth)
        return auth()->check();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, mixed>
     */
    public function rules()
    {
        return [
            // Primary key - required dan unique
            'KODEBRG' => [
                'required',
                'string',
                'max:20',
                Rule::unique('DBBARANG', 'KODEBRG')
            ],
            
            // Nama barang - required
            'NAMABRG' => [
                'required',
                'string',
                'max:100'
            ],
            
            // Kategori - optional tapi harus ada di master
            'KODEKTG' => [
                'nullable',
                'string',
                'max:10',
                Rule::exists('DBKATEGORI', 'KODEKTG')
            ],
            
            // Kelompok - optional tapi harus ada di master  
            'KODEKEL' => [
                'nullable',
                'string', 
                'max:10',
                Rule::exists('DBKELOMPOK', 'KODEKEL')
            ],
            
            // Satuan - required
            'SATUAN' => [
                'required',
                'string',
                'max:10'
            ],
            
            // Harga - harus positif
            'HARGABELI' => [
                'nullable',
                'numeric',
                'min:0',
                'max:999999999.99'
            ],
            
            'HARGAJUAL' => [
                'nullable', 
                'numeric',
                'min:0',
                'max:999999999.99',
                'gte:HARGABELI' // Harga jual >= harga beli
            ],
            
            // Stock minimum dan maximum
            'STOKMIN' => [
                'nullable',
                'integer',
                'min:0'
            ],
            
            'STOKMAX' => [
                'nullable',
                'integer',
                'min:0',
                'gte:STOKMIN' // Stock max >= stock min
            ],
            
            // Boolean fields
            'ISAKTIF' => 'boolean',
            'NFix' => 'boolean',
            'IsTakeIn' => 'boolean',
            'IsBarang' => 'boolean',
            'IsJasa' => 'boolean',
            
            // Optional text fields
            'KETERANGAN' => 'nullable|string|max:500',
            'MERK' => 'nullable|string|max:50',
            'MODEL' => 'nullable|string|max:50',
            'SPESIFIKASI' => 'nullable|string|max:1000',
        ];
    }
    
    /**
     * Get custom error messages
     */
    public function messages()
    {
        return [
            'KODEBRG.required' => 'Kode barang wajib diisi',
            'KODEBRG.unique' => 'Kode barang sudah ada, gunakan kode lain',
            'KODEBRG.max' => 'Kode barang maksimal 20 karakter',
            
            'NAMABRG.required' => 'Nama barang wajib diisi',
            'NAMABRG.max' => 'Nama barang maksimal 100 karakter',
            
            'KODEKTG.exists' => 'Kategori tidak ditemukan dalam master kategori',
            'KODEKEL.exists' => 'Kelompok tidak ditemukan dalam master kelompok',
            
            'SATUAN.required' => 'Satuan wajib diisi',
            
            'HARGABELI.min' => 'Harga beli tidak boleh negatif',
            'HARGAJUAL.min' => 'Harga jual tidak boleh negatif',
            'HARGAJUAL.gte' => 'Harga jual harus lebih besar atau sama dengan harga beli',
            
            'STOKMIN.min' => 'Stock minimum tidak boleh negatif',
            'STOKMAX.min' => 'Stock maximum tidak boleh negatif',
            'STOKMAX.gte' => 'Stock maximum harus lebih besar atau sama dengan stock minimum',
        ];
    }
    
    /**
     * Get custom attribute names
     */
    public function attributes()
    {
        return [
            'KODEBRG' => 'kode barang',
            'NAMABRG' => 'nama barang',
            'KODEKTG' => 'kategori',
            'KODEKEL' => 'kelompok',
            'SATUAN' => 'satuan',
            'HARGABELI' => 'harga beli',
            'HARGAJUAL' => 'harga jual',
            'STOKMIN' => 'stock minimum',
            'STOKMAX' => 'stock maximum',
        ];
    }
    
    /**
     * Configure validator instance
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Custom validation logic
            if ($this->HARGABELI && $this->HARGAJUAL) {
                $marginPercent = (($this->HARGAJUAL - $this->HARGABELI) / $this->HARGABELI) * 100;
                
                // Warn jika margin terlalu kecil (< 10%)
                if ($marginPercent < 10) {
                    $validator->addFailure('HARGAJUAL', 'Margin keuntungan terlalu kecil (< 10%)');
                }
                
                // Warn jika margin terlalu besar (> 300%)
                if ($marginPercent > 300) {
                    $validator->addFailure('HARGAJUAL', 'Margin keuntungan terlalu besar (> 300%)');
                }
            }
        });
    }
}
