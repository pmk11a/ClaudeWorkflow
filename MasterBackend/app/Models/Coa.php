<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coa extends Model
{
    use HasFactory;

    protected $table = 'coa';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'no', 'Perkiraan', 'Keterangan', 'Kelompok', 'Tipe', 'DK'
    ];

    protected $casts = [
        'no' => 'decimal:2',
        'Perkiraan' => 'decimal:2',
        'Kelompok' => 'decimal:2',
        'Tipe' => 'decimal:2',
        'DK' => 'decimal:2',
    ];

}
