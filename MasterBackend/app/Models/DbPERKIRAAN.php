<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPERKIRAAN extends Model
{
    use HasFactory;

    protected $table = 'DBPERKIRAAN';
    protected $primaryKey = 'Perkiraan';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Keterangan', 'Kelompok', 'Tipe', 'Valas', 'DK', 'Neraca', 'FlagCashFlow', 'Simbol', 'IsPPN', 'GroupPerkiraan', 'MyID', 'Lokasi', 'IsSubPerkiraan', 'id', 'parentid', 'KetNeraca', 'KodeAK', 'KodeSAK', 'KodeAN', 'KodePAN', 'IsNonLedger', 'IsInvestasi'
    ];

    protected $casts = [
        'IsPPN' => 'boolean',
        'MyID' => 'datetime',
        'IsSubPerkiraan' => 'boolean',
        'IsNonLedger' => 'boolean',
        'IsInvestasi' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbPERKIRAANDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}