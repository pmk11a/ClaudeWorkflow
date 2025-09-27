<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbDevGudang extends Model
{
    use HasFactory;

    protected $table = 'DbDevGudang';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Devisi', 'KodeGdg'
    ];

}
