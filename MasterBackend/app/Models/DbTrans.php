<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTrans extends Model
{
    use HasFactory;

    protected $table = 'dbTrans';
    protected $primaryKey = 'NoBukti';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'NOURUT', 'Tanggal', 'Note', 'Lampiran', 'MyID', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'Simbol', 'TipeTransHd', 'PerkiraanHd', 'FlagSimbol', 'MaxOL', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'Flagtipe', 'Jenis', 'NoBuktiSem', 'Devisi'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
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

}
