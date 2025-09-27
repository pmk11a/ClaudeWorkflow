<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SaldoApril extends Model
{
    use HasFactory;

    protected $table = 'SaldoApril';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'SUBP', 'NAPE', 'SALDO'
    ];

    protected $casts = [
        'SALDO' => 'decimal:2',
    ];

}
