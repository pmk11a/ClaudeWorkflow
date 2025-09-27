<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CoaDApen extends Model
{
    use HasFactory;

    protected $table = 'CoaDApen';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Keterangan', 'Kelompok', 'Tipe', 'Transaksi', 'NamaAK', 'NamaSubAK', 'Non Ledger', 'Investasi', 'Perubahan Aser Netto', 'Nama Perubahan Aser Neto'
    ];

}
