<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJENISCUSTSUPP extends Model
{
    use HasFactory;

    protected $table = 'DBJENISCUSTSUPP';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeJenis', 'NamaJenis'
    ];

}
