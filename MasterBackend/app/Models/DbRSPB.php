<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbRSPB extends Model
{
    use HasFactory;

    protected $table = 'DBRSPB';
    protected $primaryKey = 'NoBukti';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'NoUrut', 'Tanggal', 'NoSPB', 'KodeCustSupp', 'NoPolKend', 'Container', 'NoContainer', 'NoSeal', 'Catatan', 'IsCetak', 'IDUser', 'MyID', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'IsEkstern', 'CustAngkutan', 'IsFlag', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'KodeGdg', 'MaxOL', 'Flagtipe'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'IsCetak' => 'boolean',
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
        'IsEkstern' => 'boolean',
        'IsFlag' => 'boolean',
        'TglJurnal' => 'datetime',
    ];

}
