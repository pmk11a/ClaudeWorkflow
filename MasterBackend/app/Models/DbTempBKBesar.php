<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTempBKBesar extends Model
{
    use HasFactory;

    protected $table = 'dbTempBKBesar';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Devisi', 'NoACC', 'NamaACC', 'Transaksi', 'NoBukti', 'Tanggal', 'Keterangan', 'Perkiraan', 'Lawan', 'Debet', 'Kredit', 'Saldo', 'SaldoAwal', 'Bulan', 'Tahun', 'Urut', 'DebetD', 'KreditD', 'SaldoAwalD', 'Valas', 'Kurs'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'Debet' => 'decimal:2',
        'Kredit' => 'decimal:2',
        'Saldo' => 'decimal:2',
        'SaldoAwal' => 'decimal:2',
        'DebetD' => 'decimal:2',
        'KreditD' => 'decimal:2',
        'SaldoAwalD' => 'decimal:2',
        'Kurs' => 'decimal:2',
    ];

}
