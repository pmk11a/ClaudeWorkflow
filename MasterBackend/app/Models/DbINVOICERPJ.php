<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbINVOICERPJ extends Model
{
    use HasFactory;

    protected $table = 'DBINVOICERPJ';
    protected $primaryKey = 'NoBukti';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'NoUrut', 'Tanggal', 'TglJatuhTempo', 'KODECUSTSUPP', 'NoInvoice', 'TglInvoice', 'NORPJ', 'KODEVLS', 'KURS', 'PPN', 'TIPEBAYAR', 'HARI', 'IDUser', 'MyID', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'IsFlag', 'MaxOL', 'IsBatal', 'UserBatal', 'TglBatal', 'Flagtipe', 'KodeSLS', 'catatan', 'iscetak', 'CetakKe', 'TipePPN', 'Disc'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'TglJatuhTempo' => 'datetime',
        'TglInvoice' => 'datetime',
        'KURS' => 'decimal:2',
        'MyID' => 'datetime',
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
        'IsFlag' => 'boolean',
        'IsBatal' => 'boolean',
        'TglBatal' => 'datetime',
        'Flagtipe' => 'boolean',
        'iscetak' => 'boolean',
        'Disc' => 'decimal:2'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbINVOICERPJDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}