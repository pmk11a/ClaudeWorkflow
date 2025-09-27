<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPERUSAHAAN extends Model
{
    use HasFactory;

    protected $table = 'DBPERUSAHAAN';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEUSAHA', 'NAMA', 'ALAMAT1', 'ALAMAT2', 'KOTA', 'Telpon', 'Fax', 'NAMAPKP', 'ALAMATPKP1', 'ALAMATPKP2', 'KOTAPKP', 'NPWP', 'TGLPENGUKUHAN', 'NAMAPKP1', 'ALAMATPKP21', 'ALAMATPKP22', 'KOTAPKP1', 'NPWP1', 'TGLPENGUKUHAN1', 'Direksi', 'Jabatan', 'LOGO', 'TTD', 'email'
    ];

    protected $casts = [
        'TGLPENGUKUHAN' => 'datetime',
        'TGLPENGUKUHAN1' => 'datetime',
    ];

}
