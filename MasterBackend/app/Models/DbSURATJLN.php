<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSURATJLN extends Model
{
    use HasFactory;

    protected $table = 'DBSURATJLN';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'KODECUST', 'NOSO', 'NOPNJ', 'NoAlamatKirim', 'AlamatKirim', 'KODEGDG', 'SOPIR', 'KETERANGAN', 'CATATAN', 'ISCETAK', 'ISBATAL', 'USERBATAL', 'KETBATAL', 'KodeExp', 'INSGdg', 'INSBrg', 'NewNo', 'TGLShipment', 'KotaAsal', 'TGLTiba', 'KotaTujuan', 'Vessel', 'Cont', 'NoCont', 'NoSeal', 'FlagTipe'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'ISBATAL' => 'boolean',
        'TGLShipment' => 'datetime',
        'TGLTiba' => 'datetime',
    ];

}
