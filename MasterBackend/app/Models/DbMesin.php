<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbMesin extends Model
{
    use HasFactory;

    protected $table = 'DBMesin';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeMsn', 'Ket', 'KodePrs', 'Kapasitas'
    ];

    protected $casts = [
        'Kapasitas' => 'decimal:2',
    ];

}
