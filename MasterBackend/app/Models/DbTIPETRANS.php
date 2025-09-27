<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTIPETRANS extends Model
{
    use HasFactory;

    protected $table = 'DBTIPETRANS';
    protected $primaryKey = 'KODETIPE';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODETIPE', 'Nama', 'IsJasaBeliJual'
    ];

}
