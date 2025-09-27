<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJADWALPRDOLD extends Model
{
    use HasFactory;

    protected $table = 'DBJADWALPRDOLD';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOJADWAL', 'KODEMSN', 'TANGGAL', 'JAMAWAL', 'JAMAKHIR', 'ISPRODUKSI', 'NOSPK', 'KETERANGAN', 'QNTSPK', 'QNTKERJA'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'JAMAWAL' => 'datetime',
        'JAMAKHIR' => 'datetime',
        'ISPRODUKSI' => 'boolean',
        'QNTSPK' => 'decimal:2',
        'QNTKERJA' => 'decimal:2',
    ];

}
