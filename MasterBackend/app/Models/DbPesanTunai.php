<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPesanTunai extends Model
{
    use HasFactory;

    protected $table = 'dbPesanTunai';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NoUrut', 'TANGGAL', 'KODECUST', 'ISCETAK', 'BayarTunai', 'BayarDebet', 'NoDebet', 'BankDebet', 'BayarKredit', 'TipeKartuKredit', 'NoKredit', 'BankKredit', 'BayarVoucher', 'VoucherRp', 'TglInput', 'UserID', 'DiscMember', 'DiscHarian', 'Keterangan', 'KodeRekan', 'NoKartuRekan', 'DiscRekan', 'Pemesan', 'IsOrder', 'IsAmbil', 'Alamat', 'Telepon', 'TanggalAmbil', 'DP', 'KodeGdg', 'TglKirim', 'JamKirim', 'Piutang', 'IsAmbilBrg'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'ISCETAK' => 'boolean',
        'TglInput' => 'datetime',
        'DiscMember' => 'decimal:2',
        'DiscHarian' => 'decimal:2',
        'DiscRekan' => 'decimal:2',
        'IsOrder' => 'boolean',
        'IsAmbil' => 'boolean',
        'TanggalAmbil' => 'datetime',
        'TglKirim' => 'datetime',
        'IsAmbilBrg' => 'boolean'
    ];


    // Relationships
    public function customer_supplier()
    {
        return $this->belongsTo(Dbcustsupp::class, 'KODECUST', 'KODECUSTSUPP');
    }

    public function details()
    {
        return $this->hasMany(DbPesanTunaiDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}