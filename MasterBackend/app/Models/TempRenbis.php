<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempRenbis extends Model
{
    use HasFactory;

    protected $table = 'TempRenbis';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Jenis', 'Grup', 'Keterangan', 'SeptemberTahunIni', 'DesemberTahunIni', 'JuniTahunYAD', 'DesemberTahunYAD'
    ];

    protected $casts = [
        'SeptemberTahunIni' => 'decimal:2',
        'DesemberTahunIni' => 'decimal:2',
        'JuniTahunYAD' => 'decimal:2',
        'DesemberTahunYAD' => 'decimal:2',
    ];

}
