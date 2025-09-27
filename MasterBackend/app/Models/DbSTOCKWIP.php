<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSTOCKWIP extends Model
{
    use HasFactory;

    protected $table = 'dbSTOCKWIP';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOSPK', 'BULAN', 'TAHUN', 'KODEPRS', 'KODEBRG', 'QntAwal', 'Qnt2Awal', 'HrgAwal', 'QntMasuk', 'Qnt2Masuk', 'HrgProses_', 'HrgBahan', 'ByProses', 'HrgMasuk', 'QntKeluar', 'Qnt2Keluar', 'HrgKeluar', 'QntAkhir', 'Qnt2Akhir', 'HrgAkhir'
    ];

    protected $casts = [
        'QntAwal' => 'decimal:2',
        'Qnt2Awal' => 'decimal:2',
        'HrgAwal' => 'decimal:2',
        'QntMasuk' => 'decimal:2',
        'Qnt2Masuk' => 'decimal:2',
        'HrgProses_' => 'decimal:2',
        'HrgBahan' => 'decimal:2',
        'ByProses' => 'decimal:2',
        'HrgMasuk' => 'decimal:2',
        'QntKeluar' => 'decimal:2',
        'Qnt2Keluar' => 'decimal:2',
        'HrgKeluar' => 'decimal:2',
        'QntAkhir' => 'decimal:2',
        'Qnt2Akhir' => 'decimal:2',
        'HrgAkhir' => 'decimal:2',
    ];

}
