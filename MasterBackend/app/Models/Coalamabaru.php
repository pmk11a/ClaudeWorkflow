<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coalamabaru extends Model
{
    use HasFactory;

    protected $table = 'coalamabaru';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Lama', 'KetLama', 'Baru', 'KetBaru'
    ];

}
