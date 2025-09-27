<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbRNeracaBulanan extends Model
{
    use HasFactory;

    protected $table = 'DBRNeracaBulanan';
    protected $primaryKey = 'Perkiraan';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Keterangan', 'DK', 'GroupPerkiraan', 'IsSubPerkiraan', 'Tanda'
    ];

    protected $casts = [
        'IsSubPerkiraan' => 'boolean',
    ];

}
