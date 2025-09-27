<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPRoses extends Model
{
    use HasFactory;

    protected $table = 'DBPRoses';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodePrs', 'Keterangan', 'KodeGdg'
    ];

}
