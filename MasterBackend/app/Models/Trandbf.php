<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Trandbf extends Model
{
    use HasFactory;

    protected $table = 'trandbf';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'PERK', 'SUBP', 'NOBU', 'TGBU', 'BARI', 'URAI', 'JUML', 'SALD', 'SALDS', 'KODE', 'CAS', 'USR_MAINT', 'TGL_MAINT'
    ];

    protected $casts = [
        'TGBU' => 'datetime',
        'BARI' => 'decimal:2',
        'JUML' => 'decimal:2',
        'SALD' => 'decimal:2',
        'TGL_MAINT' => 'datetime',
    ];

}
