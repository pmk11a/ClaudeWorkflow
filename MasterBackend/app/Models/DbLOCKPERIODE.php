<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbLOCKPERIODE extends Model
{
    use HasFactory;

    protected $table = 'DBLOCKPERIODE';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'BULAN', 'TAHUN'
    ];

}
