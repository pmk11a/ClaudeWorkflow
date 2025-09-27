<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbInvoicePL extends Model
{
    use HasFactory;

    protected $table = 'dbInvoicePL';
    protected $primaryKey = 'NoBukti';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'NoUrut', 'Tanggal', 'DISC', 'PPN', 'Valas', 'Kurs', 'NoSPP', 'KodeCustSupp', 'Consignee', 'NotifyParty', 'StuffingDate', 'StuffingPlace', 'ContractNo', 'PONo', 'PaymentTerm', 'DocCreditNo', 'PoL', 'PoD', 'NameOfVessel', 'Feeder_Vessel', 'Connect_Vessel', 'ShipOnBoardDate', 'Packing', 'Others', 'IsCetak', 'IDUser', 'IsLokal', 'NoBL', 'NoteBeneficiary1', 'NoteBeneficiary2', 'NoteBeneficiary3', 'ShipmentAdvice1', 'ShipmentAdvice2', 'ETADestination', 'ToShipmentAdvice2', 'NoPajak', 'TglFPJ', 'Footnote', 'IssuingBank', 'MyID', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'IsFLag', 'MAXOL', 'NoKMK', 'TglKMK', 'IsBatal', 'UserBatal', 'TglBatal', 'FlagTipe', 'KodeFP', 'Usercetak', 'TglCetak', 'CetakKe', 'NoUMJ', 'DppUMJ', 'NppUMJ', 'PersenUMJ'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'DISC' => 'decimal:2',
        'Kurs' => 'decimal:2',
        'StuffingDate' => 'datetime',
        'ShipOnBoardDate' => 'datetime',
        'IsCetak' => 'boolean',
        'IsLokal' => 'boolean',
        'ETADestination' => 'datetime',
        'TglFPJ' => 'datetime',
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
        'TglKMK' => 'datetime',
        'IsBatal' => 'boolean',
        'TglBatal' => 'datetime',
        'FlagTipe' => 'boolean',
        'TglCetak' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbInvoicePLDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}