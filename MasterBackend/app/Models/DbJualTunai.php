<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJualTunai extends Model
{
    use HasFactory;

    protected $table = 'dbJualTunai';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NoUrut', 'TANGGAL', 'KODECUST', 'ISCETAK', 'BayarTunai', 'BayarDebet', 'NoDebet', 'BankDebet', 'BayarKredit', 'TipeKartuKredit', 'NoKredit', 'BankKredit', 'BayarVoucher', 'VoucherRp', 'TglInput', 'UserID', 'DiscMember', 'DiscHarian', 'Keterangan', 'KodeRekan', 'NoKartuRekan', 'DiscRekan', 'Pemesan', 'IsOrder', 'Alamat', 'Telepon', 'TanggalAmbil', 'DP', 'Piutang'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'ISCETAK' => 'boolean',
        'TglInput' => 'datetime',
        'DiscMember' => 'decimal:2',
        'DiscHarian' => 'decimal:2',
        'DiscRekan' => 'decimal:2',
        'IsOrder' => 'boolean',
        'TanggalAmbil' => 'datetime'
    ];


    // Relationships
    public function customer_supplier()
    {
        return $this->belongsTo(Dbcustsupp::class, 'KODECUST', 'KODECUSTSUPP');
    }

    public function details()
    {
        return $this->hasMany(DbJualTunaiDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}