<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SaldoAwalSub extends Model
{
    use HasFactory;

    protected $table = 'SaldoAwalSub';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOPE', 'SUBP', 'NAPE', 'SALDO', 'DEBT', 'KRED', 'TGL', 'USR_MAINT'
    ];

    protected $casts = [
        'SALDO' => 'decimal:2',
        'DEBT' => 'decimal:2',
        'KRED' => 'decimal:2',
    ];

}
