<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class XlsNilaiPasar extends Model
{
    use HasFactory;

    protected $table = 'xlsNilaiPasar';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Urut', 'Tahun', 'Bulan', 'Perkiraan', 'Keterangan', 'NilaiPerolehan', 'NilaiPasar', 'KetExcel', 'PasarExcel'
    ];

    protected $casts = [
        'NilaiPerolehan' => 'decimal:2',
        'NilaiPasar' => 'decimal:2',
        'PasarExcel' => 'decimal:2',
    ];

}
