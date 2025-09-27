<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbInvoice extends Model
{
    use HasFactory;

    protected $table = 'DBInvoice';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'KETERANGAN', 'KodeSupp', 'NoPO', 'NoFaktur', 'TglJatuhTempo', 'KodeVls', 'Kurs', 'PPN', 'TipeBayar', 'Hari', 'TipeDisc', 'DISC', 'DISCRP', 'ISCETAK', 'NilaiCetak', 'IDUser', 'IsBatal', 'UserBatal', 'KodeExp', 'cetakke', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL', 'TglBatal', 'Flagtipe', 'TipePPN', 'NoFakturPajak', 'TglFakturPajak', 'NoBuktiPotong', 'TglBuktiPotong', 'NoInvoice', 'TglInvoice'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TglJatuhTempo' => 'datetime',
        'Kurs' => 'decimal:2',
        'TipeDisc' => 'boolean',
        'DISCRP' => 'decimal:2',
        'ISCETAK' => 'boolean',
        'IsBatal' => 'boolean',
        'IsOtorisasi1' => 'boolean',
        'TglOto1' => 'datetime',
        'IsOtorisasi2' => 'boolean',
        'TglOto2' => 'datetime',
        'IsOtorisasi3' => 'boolean',
        'TglOto3' => 'datetime',
        'IsOtorisasi4' => 'boolean',
        'TglOto4' => 'datetime',
        'IsOtorisasi5' => 'boolean',
        'TglOto5' => 'datetime',
        'TglJurnal' => 'datetime',
        'TglBatal' => 'datetime',
        'Flagtipe' => 'boolean',
        'TglFakturPajak' => 'datetime',
        'TglBuktiPotong' => 'datetime',
        'TglInvoice' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbInvoiceDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}