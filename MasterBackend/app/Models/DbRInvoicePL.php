<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbRInvoicePL extends Model
{
    use HasFactory;

    protected $table = 'DBRInvoicePL';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'TGLJATUHTEMPO', 'KODECUSTSUPP', 'NoInvoice', 'TglInvoice', 'NoSO', 'TglSO', 'NoSPP', 'TglSPP', 'NOSPB', 'TGLSPB', 'KODEVLS', 'KURS', 'PPN', 'TIPEBAYAR', 'HARI', 'Tipe', 'DISC', 'DISCRP', 'NILAIPOT', 'NILAIDPP', 'NILAIPPN', 'NILAINET', 'NILAIPOTRp', 'NILAIDPPRp', 'NILAIPPNRp', 'NILAINETRp', 'FREIGHT', 'LAIN2', 'ISCETAK', 'ISCETAKGDG', 'ISBATAL', 'USERBATAL', 'IDUser', 'FlagRetur', 'IsLokal', 'MyID', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'IsFLag', 'NoLKP', 'TGLLKP', 'MaxOL', 'TglBatal'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TGLJATUHTEMPO' => 'datetime',
        'TglInvoice' => 'datetime',
        'TglSO' => 'datetime',
        'TglSPP' => 'datetime',
        'TGLSPB' => 'datetime',
        'KURS' => 'decimal:2',
        'DISCRP' => 'decimal:2',
        'NILAIPOT' => 'decimal:2',
        'NILAIDPP' => 'decimal:2',
        'NILAIPPN' => 'decimal:2',
        'NILAINET' => 'decimal:2',
        'NILAIPOTRp' => 'decimal:2',
        'NILAIDPPRp' => 'decimal:2',
        'NILAIPPNRp' => 'decimal:2',
        'NILAINETRp' => 'decimal:2',
        'ISCETAK' => 'boolean',
        'ISCETAKGDG' => 'boolean',
        'ISBATAL' => 'boolean',
        'FlagRetur' => 'boolean',
        'IsLokal' => 'boolean',
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
        'IsFLag' => 'boolean',
        'TGLLKP' => 'datetime',
        'TglBatal' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbRInvoicePLDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}