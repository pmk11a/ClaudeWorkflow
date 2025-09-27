<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempStockMinus extends Model
{
    use HasFactory;

    protected $table = 'TempStockMinus';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'IDUser', 'Urut', 'JenisBahan', 'KodeGdg', 'KodeBrg', 'KodeBng', 'KodeJenis', 'KodeWarna'
    ];

}
