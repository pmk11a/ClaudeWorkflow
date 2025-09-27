<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AT extends Model
{
    use HasFactory;

    protected $table = 'AT';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Keterangan', 'Qnt', 'TglPerolehan', 'Persen', 'NilaiAwal'
    ];

    protected $casts = [
        'Qnt' => 'decimal:2',
        'TglPerolehan' => 'datetime',
        'Persen' => 'decimal:2',
        'NilaiAwal' => 'decimal:2',
    ];

}
