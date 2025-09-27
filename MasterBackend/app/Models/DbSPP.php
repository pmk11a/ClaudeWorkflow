<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSPP extends Model
{
    use HasFactory;

    protected $table = 'dbSPP';
    protected $primaryKey = 'NoBukti';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'NoUrut', 'Tanggal', 'NoSHIP', 'NoPesan', 'KodeCustSupp', 'TglKirim', 'NoLC', 'NamaKirim', 'AlamatKirim', 'Packing', 'Catatan', 'IsCetak', 'IDUser', 'IsClose', 'IsFlag', 'MyID', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoAlamatKirim', 'isCetakKitir', 'cetakke', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL', 'IsBatal', 'UserBatal', 'TglBatal', 'FlagTipe'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'TglKirim' => 'datetime',
        'IsCetak' => 'boolean',
        'IsClose' => 'boolean',
        'IsFlag' => 'boolean',
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
        'isCetakKitir' => 'boolean',
        'TglJurnal' => 'datetime',
        'IsBatal' => 'boolean',
        'TglBatal' => 'datetime',
    ];

}
