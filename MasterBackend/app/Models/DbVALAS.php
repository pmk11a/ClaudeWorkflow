<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbVALAS extends Model
{
    use HasFactory;

    protected $table = 'dbVALAS';
    protected $primaryKey = 'KODEVLS';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEVLS', 'NAMAVLS', 'KURS', 'Simbol'
    ];

    protected $casts = [
        'KURS' => 'decimal:2',
    ];

}
