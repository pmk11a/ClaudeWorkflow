<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempOutstandingPO extends Model
{
    use HasFactory;

    protected $table = 'TempOutstandingPO';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'IDUser', 'IsTerima', 'NOBUKTI', 'Tanggal', 'KeyNoBukti', 'URUT', 'FlagTipe', 'KODEBRG', 'KodeWarna', 'NAMABRG', 'PPN', 'DISC', 'Kurs', 'QNT', 'NOSAT', 'SATUAN', 'ISI', 'HARGA', 'DISCP', 'DISCTOT', 'BYANGKUT', 'KetDetail', 'QntSisa', 'CollyTerima', 'QntTerima', 'DiscP2', 'DiscP3', 'DiscP4', 'DiscP5', 'KodeCustSupp', 'IsJasa', 'NOBATCH'
    ];

    protected $casts = [
        'IsTerima' => 'boolean',
        'Tanggal' => 'datetime',
        'DISC' => 'decimal:2',
        'Kurs' => 'decimal:2',
        'QNT' => 'decimal:2',
        'ISI' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'DISCP' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'BYANGKUT' => 'decimal:2',
        'QntSisa' => 'decimal:2',
        'CollyTerima' => 'decimal:2',
        'QntTerima' => 'decimal:2',
        'DiscP2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscP5' => 'decimal:2',
        'IsJasa' => 'boolean',
    ];

}
