<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PerkiraanE1 extends Model
{
    use HasFactory;

    protected $table = 'PerkiraanE1';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'SUBPerkiraaan', 'Group', 'Keterangan', 'kelompok', 'tipe', 'transaksi', 'Column 7', 'Column 8'
    ];

}
