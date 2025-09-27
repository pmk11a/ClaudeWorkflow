<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPERIODE extends Model
{
    use HasFactory;

    protected $table = 'DBPERIODE';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'USERID', 'BULAN', 'TAHUN'
    ];

}
