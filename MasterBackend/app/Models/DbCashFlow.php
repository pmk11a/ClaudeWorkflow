<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbCashFlow extends Model
{
    use HasFactory;

    protected $table = 'dbCashFlow';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Lawan', 'Keterangan', 'Kas', 'Koreksi', 'Jumlah', 'Gol', 'UserID', 'Urut', 'Devisi', 'KodeCS'
    ];

    protected $casts = [
        'Kas' => 'decimal:2',
        'Koreksi' => 'decimal:2',
        'Jumlah' => 'decimal:2',
    ];

}
