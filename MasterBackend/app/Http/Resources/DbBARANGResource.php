<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class DbBARANGResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        return [
            // Basic Information
            'kode_barang' => $this->KODEBRG,
            'nama_barang' => $this->NAMABRG,
            'kategori' => $this->KODEKTG,
            'kelompok' => $this->KODEKEL,
            'satuan' => $this->SATUAN,
            
            // Pricing Information
            'harga' => [
                'beli' => [
                    'value' => $this->HARGABELI,
                    'formatted' => 'Rp ' . number_format($this->HARGABELI, 0, ',', '.')
                ],
                'jual' => [
                    'value' => $this->HARGAJUAL,
                    'formatted' => 'Rp ' . number_format($this->HARGAJUAL, 0, ',', '.')
                ],
                'margin' => [
                    'value' => $this->HARGAJUAL - $this->HARGABELI,
                    'percentage' => $this->HARGABELI > 0 ? 
                        round((($this->HARGAJUAL - $this->HARGABELI) / $this->HARGABELI) * 100, 2) : 0
                ]
            ],
            
            // Stock Information
            'stock' => [
                'current' => $this->QTY ?? 0,
                'minimum' => $this->STOKMIN,
                'maximum' => $this->STOKMAX,
                'status' => $this->getStockStatus()
            ],
            
            // Product Details
            'details' => [
                'merk' => $this->MERK,
                'model' => $this->MODEL,
                'spesifikasi' => $this->SPESIFIKASI,
                'keterangan' => $this->KETERANGAN
            ],
            
            // Status Flags
            'status' => [
                'is_active' => (bool) $this->ISAKTIF,
                'is_fixed' => (bool) $this->NFix,
                'is_take_in' => (bool) $this->IsTakeIn,
                'is_product' => (bool) $this->IsBarang,
                'is_service' => (bool) $this->IsJasa
            ],
            
            // Meta Information
            'meta' => [
                'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
                'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
                'last_modified' => $this->updated_at?->diffForHumans(),
                'is_expensive' => $this->HARGAJUAL > 100000,
                'needs_restock' => $this->QTY <= $this->STOKMIN
            ],
            
            // Conditional fields based on request
            $this->mergeWhen($request->has('include_relationships'), [
                'kategori_detail' => $this->whenLoaded('kategori'),
                'kelompok_detail' => $this->whenLoaded('kelompok'),
            ]),
            
            // Admin only fields
            $this->mergeWhen($request->user()?->is_admin, [
                'admin_data' => [
                    'cost_price' => $this->HARGABELI,
                    'profit_margin' => $this->HARGAJUAL - $this->HARGABELI
                ]
            ])
        ];
    }
    
    /**
     * Get stock status based on current stock vs min/max
     */
    private function getStockStatus()
    {
        $current = $this->QTY ?? 0;
        $min = $this->STOKMIN ?? 0;
        $max = $this->STOKMAX ?? 0;
        
        if ($current <= 0) {
            return 'out_of_stock';
        } elseif ($current <= $min) {
            return 'low_stock';
        } elseif ($current >= $max) {
            return 'overstocked';
        } else {
            return 'normal';
        }
    }
    
    /**
     * Customize the outgoing response for the resource.
     */
    public function with($request)
    {
        return [
            'api_version' => '1.0',
            'timestamp' => now()->toISOString(),
            'links' => [
                'self' => route('barang.show', $this->KODEBRG ?? ''),
                'edit' => route('barang.edit', $this->KODEBRG ?? ''),
            ]
        ];
    }
    
    /**
     * Get additional data that should be returned with the resource array.
     */
    public function additional(array $data)
    {
        return array_merge($data, [
            'currency' => 'IDR',
            'unit_system' => 'metric'
        ]);
    }
}
