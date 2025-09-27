<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSPK extends Model
{
    use HasFactory;

    protected $table = 'DBSPK';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NoUrut', 'TANGGAL', 'KODEBRG', 'NoBatch', 'TglExpired', 'Qnt', 'IsCLose', 'Nosat', 'Satuan', 'Isi', 'KodeBOM', 'CetakKe', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TglExpired' => 'datetime',
        'Qnt' => 'decimal:2',
        'IsCLose' => 'boolean',
        'Isi' => 'decimal:2',
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
    ];


    // Relationships
    public function item()
    {
        return $this->belongsTo(DbBARANG::class, 'KODEBRG', 'KODEBRG');
    }

    public function details()
    {
        return $this->hasMany(DbSPKDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}
