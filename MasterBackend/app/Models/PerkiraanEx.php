<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PerkiraanEx extends Model
{
    use HasFactory;

    protected $table = 'PerkiraanEx';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODE BARU', 'NAMA PERKIRAAN', 'KELOMPOK', 'TIPE', 'TRANSAKSI'
    ];

}
