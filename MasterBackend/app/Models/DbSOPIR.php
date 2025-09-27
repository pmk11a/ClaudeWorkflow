<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSOPIR extends Model
{
    use HasFactory;

    protected $table = 'DBSOPIR';
    protected $primaryKey = 'KODESOPIR';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODESOPIR', 'NAMASOPIR', 'KODESG', 'IsAktif'
    ];

}
