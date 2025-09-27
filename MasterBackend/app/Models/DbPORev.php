<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPORev extends Model
{
    use HasFactory;

    protected $table = 'DBPORev';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'TglJatuhTempo', 'KODESUPP', 'HANDLING', 'KODEEXP', 'KETERANGAN', 'FAKTURSUPP', 'KODEVLS', 'KURS', 'PPN', 'TIPEBAYAR', 'HARI', 'TipeDisc', 'DISC', 'DISCRP', 'NILAIPOT', 'NILAIDPP', 'NILAIPPN', 'NILAINET', 'ISCETAK', 'NilaiCetak', 'IsBatal', 'UserBatal', 'IsClose', 'RevisiKe', 'TanggalRev', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TglJatuhTempo' => 'datetime',
        'HANDLING' => 'decimal:2',
        'KURS' => 'decimal:2',
        'TipeDisc' => 'boolean',
        'DISCRP' => 'decimal:2',
        'NILAIPOT' => 'decimal:2',
        'NILAIDPP' => 'decimal:2',
        'NILAIPPN' => 'decimal:2',
        'NILAINET' => 'decimal:2',
        'ISCETAK' => 'boolean',
        'IsBatal' => 'boolean',
        'IsClose' => 'boolean',
        'TanggalRev' => 'datetime',
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
        'TglJurnal' => 'datetime'
    ];


    // Relationships
    public function customer_supplier()
    {
        return $this->belongsTo(Dbcustsupp::class, 'KODESUPP', 'KODECUSTSUPP');
    }

    public function details()
    {
        return $this->hasMany(DbPORevDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}