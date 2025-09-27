<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbMyUrutan extends Model
{
    use HasFactory;

    protected $table = 'dbMyUrutan';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeData', 'Urutan', 'KodeUrutan'
    ];

}
