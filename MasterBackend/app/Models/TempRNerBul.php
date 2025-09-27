<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempRNerBul extends Model
{
    use HasFactory;

    protected $table = 'TempRNerBul';
    protected $primaryKey = 'Perkiraan';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Keterangan', 'DK', 'GroupPerkiraan', 'IsSubPerkiraan', 'Tanda', 'Awal', 'AwalK', 'Debet', 'DebetK', 'Kredit', 'KreditK', 'Akhir', 'AkhirK', 'Bintang', 'Budget', 'Bulan', 'Tahun'
    ];

    protected $casts = [
        'IsSubPerkiraan' => 'boolean',
        'Awal' => 'decimal:2',
        'Debet' => 'decimal:2',
        'Kredit' => 'decimal:2',
        'Akhir' => 'decimal:2',
        'Budget' => 'decimal:2',
    ];

}
