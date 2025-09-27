<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPBIAYA extends Model
{
    use HasFactory;

    protected $table = 'DBPBIAYA';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Kodebiaya', 'Keterangan', 'Nilai', 'KodeVls', 'Kurs', 'NoBuktiInv', 'Urut'
    ];

    protected $casts = [
        'Nilai' => 'decimal:2',
        'Kurs' => 'decimal:2',
    ];

}
