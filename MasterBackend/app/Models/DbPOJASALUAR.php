<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPOJASALUAR extends Model
{
    use HasFactory;

    protected $table = 'DBPOJASALUAR';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'TglJatuhTempo', 'KODESUPP', 'HANDLING', 'KODEEXP', 'KETERANGAN', 'FAKTURSUPP', 'KODEVLS', 'KURS', 'PPN', 'TIPEBAYAR', 'HARI', 'TipeDisc', 'DISC', 'DISCRP', 'ISCETAK', 'NilaiCetak', 'IsBatal', 'UserBatal', 'IsClose', 'IsExp', 'isAut', 'KodeGDG', 'cetakke', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL', 'TglBatal', 'flagtipe', 'TipePPN'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TglJatuhTempo' => 'datetime',
        'HANDLING' => 'decimal:2',
        'KURS' => 'decimal:2',
        'TipeDisc' => 'boolean',
        'DISCRP' => 'decimal:2',
        'ISCETAK' => 'boolean',
        'IsBatal' => 'boolean',
        'IsClose' => 'boolean',
        'IsExp' => 'boolean',
        'isAut' => 'boolean',
        'IsOtorisasi1' => 'boolean',
        'TglOto1' => 'datetime',
        'IsOtorisasi2' => 'boolean',
        'TglOto2' => 'datetime',
        'IsOtorisasi3' => 'boolean',
        'TglOto3' => 'datetime',
        'IsOtorisasi4' => 'boolean',
        'TglOto4' => 'datetime',
        'IsOtorisasi5' => 'boolean',
        'TglOto5' => 'datetime',
        'TglJurnal' => 'datetime',
        'TglBatal' => 'datetime',
        'flagtipe' => 'boolean'
    ];


    // Relationships
    public function customer_supplier()
    {
        return $this->belongsTo(Dbcustsupp::class, 'KODESUPP', 'KODECUSTSUPP');
    }

    public function details()
    {
        return $this->hasMany(DbPOJASALUARDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}