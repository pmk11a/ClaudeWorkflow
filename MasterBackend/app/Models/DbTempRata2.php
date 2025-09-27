<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTempRata2 extends Model
{
    use HasFactory;

    protected $table = 'dbTempRata2';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeGdg', 'QntSaldo', 'HrgSaldo', 'HrgRata'
    ];

    protected $casts = [
        'QntSaldo' => 'decimal:2',
        'HrgSaldo' => 'decimal:2',
        'HrgRata' => 'decimal:2',
    ];

}
