<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBARANG extends Model
{
    use HasFactory;

    protected $table = 'DBBARANG';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEBRG', 'NAMABRG', 'KODEGRP', 'KODESUBGRP', 'KODESUPP', 'SAT1', 'ISI1', 'SAT2', 'ISI2', 'SAT3', 'ISI3', 'Hrg1_1', 'Hrg2_1', 'Hrg3_1', 'Hrg1_2', 'Hrg2_2', 'Hrg3_2', 'Hrg1_3', 'Hrg2_3', 'Hrg3_3', 'QntMin', 'QntMax', 'ISAKTIF', 'Keterangan', 'NFix', 'NamaBrg2', 'Tolerate', 'Proses', 'IsTakeIn', 'IsBarang', 'IsJasa', 'KodeMerk', 'KodeHdGrp'
    ];

    protected $casts = [
        'QntMin' => 'decimal:2',
        'QntMax' => 'decimal:2',
        'ISAKTIF' => 'boolean',
        'NFix' => 'boolean',
        'IsTakeIn' => 'boolean',
        'IsBarang' => 'boolean',
        'IsJasa' => 'boolean'
    ];

    // Query Scopes untuk Optimization
    public function scopeActive($query)
    {
        return $query->where('ISAKTIF', true);
    }
    
    public function scopeByCategory($query, $category)
    {
        return $query->where('KODEKTG', $category);
    }
    
    public function scopeByGroup($query, $group)
    {
        return $query->where('KODEKEL', $group);
    }
    
    public function scopePriceRange($query, $minPrice, $maxPrice)
    {
        return $query->whereBetween('HARGAJUAL', [$minPrice, $maxPrice]);
    }
    
    public function scopeLowStock($query)
    {
        return $query->whereColumn('QTY', '<=', 'STOKMIN');
    }
    
    public function scopeExpensive($query, $threshold = 100000)
    {
        return $query->where('HARGAJUAL', '>=', $threshold);
    }
    
    public function scopeSearch($query, $search)
    {
        return $query->where(function($q) use ($search) {
            $q->where('KODEBRG', 'like', "%{$search}%")
              ->orWhere('NAMABRG', 'like', "%{$search}%")
              ->orWhere('MERK', 'like', "%{$search}%");
        });
    }
    
    public function scopeWithStock($query)
    {
        return $query->where('QTY', '>', 0);
    }
    
    public function scopeOrderByStock($query, $direction = 'asc')
    {
        return $query->orderBy('QTY', $direction);
    }
    
    public function scopePopular($query, $limit = 10)
    {
        // Scope untuk barang yang sering dijual (bisa disesuaikan dengan logika bisnis)
        return $query->where('ISAKTIF', true)
                    ->orderBy('HARGAJUAL', 'desc')
                    ->limit($limit);
    }

    // Relationships
    public function item()
    {
        return $this->belongsTo(Dbbarang::class, 'KODEBRG', 'KODEBRG');
    }

    public function group()
    {
        return $this->belongsTo(DbGROUP::class, 'KODEGRP', 'KODEGRP');
    }

    public function customer_supplier()
    {
        return $this->belongsTo(Dbcustsupp::class, 'KODESUPP', 'KODECUSTSUPP');
    }

    public function details()
    {
        return $this->hasMany(DbBARANGDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}