<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTempHUTPIUT extends Model
{
    use HasFactory;

    protected $table = 'DBTempHUTPIUT';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoFaktur', 'NoRetur', 'TipeTrans', 'KodeCustSupp', 'NoBukti', 'NoMsk', 'Urut', 'Tanggal', 'JatuhTempo', 'Debet', 'Kredit', 'Saldo', 'Valas', 'Kurs', 'DebetD', 'KreditD', 'SaldoD', 'KodeSales', 'Tipe', 'Perkiraan', 'Catatan', 'MyID', 'IDUser', 'StatusUID', 'JumlahSaldo', 'JumlahSaldoD', 'TipeDK', 'NoInvoice', 'Valas_', 'Kurs_', 'KursBayar', 'FlagSimbol'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'JatuhTempo' => 'datetime',
        'Debet' => 'decimal:2',
        'Kredit' => 'decimal:2',
        'Saldo' => 'decimal:2',
        'Kurs' => 'decimal:2',
        'DebetD' => 'decimal:2',
        'KreditD' => 'decimal:2',
        'SaldoD' => 'decimal:2',
        'JumlahSaldo' => 'decimal:2',
        'JumlahSaldoD' => 'decimal:2',
        'Kurs_' => 'decimal:2',
        'KursBayar' => 'decimal:2',
    ];

}
