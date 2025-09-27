<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class XLSPembelian extends Model
{
    use HasFactory;

    protected $table = 'XLSPembelian';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KeyUrut', 'NoBukti', 'Urut', 'Tanggal', 'JatuhTempo', 'NoBukti_', 'PPn', 'KodeCustSupp', 'KodeTipe', 'KodeSubTipe', 'Qnt', 'Harga', 'KodeVls', 'Kurs', 'NDPP', 'NPPN', 'NNet', 'NDPPD', 'NPPND', 'NNetD', 'AccPersediaan', 'AccPPN', 'AccHutPiut', 'IsExcel'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'JatuhTempo' => 'datetime',
        'Qnt' => 'decimal:2',
        'Harga' => 'decimal:2',
        'Kurs' => 'decimal:2',
        'NDPP' => 'decimal:2',
        'NPPN' => 'decimal:2',
        'NNet' => 'decimal:2',
        'NDPPD' => 'decimal:2',
        'NPPND' => 'decimal:2',
        'NNetD' => 'decimal:2',
        'IsExcel' => 'boolean',
    ];

}
