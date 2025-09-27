<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbCUSTSUPP extends Model
{
    use HasFactory;

    protected $table = 'DBCUSTSUPP';
    protected $primaryKey = 'KODECUSTSUPP';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODECUSTSUPP', 'NAMACUSTSUPP', 'ALAMAT1', 'ALAMAT2', 'Kota', 'TELPON', 'FAX', 'EMAIL', 'KODEPOS', 'NEGARA', 'NPWP', 'Tanggal', 'PLAFON', 'HARI', 'HARIHUTPIUT', 'BERIKAT', 'USAHA', 'PERKIRAAN', 'JENIS', 'NAMAPKP', 'ALAMATPKP1', 'ALAMATPKP2', 'KOTAPKP', 'Sales', 'KodeVls', 'KodeExp', 'KodeTipe', 'IsPpn', 'IsAktif', 'Kind', 'ContactP', 'Alamat1ContP', 'Alamat2ContP', 'KotaContP', 'NegaraContP', 'TelpContP', 'FaxContP', 'EmailContP', 'KODEPOSContP', 'HPContP', 'SyaratPenerimaan', 'SyaratPembayaran', 'Agent', 'Alamat1A', 'Alamat2A', 'KotaA', 'NegaraA', 'ContactA', 'TelpA', 'FaxA', 'EmailA', 'KODEPOSA', 'HPA', 'EmailContA', 'MyID', 'PortOfLoading', 'CountryOfOrigin', 'TglInput', 'iskontrak', 'PPN', 'HargaKe', 'Att', 'bank', 'NoAcc', 'IsMember', 'TanggalValid', 'DiscMember', 'AttPhone', 'ket', 'JenisCustSupp'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'PLAFON' => 'decimal:2',
        'BERIKAT' => 'boolean',
        'IsPpn' => 'boolean',
        'IsAktif' => 'boolean',
        'MyID' => 'datetime',
        'TglInput' => 'datetime',
        'iskontrak' => 'boolean',
        'IsMember' => 'boolean',
        'TanggalValid' => 'datetime',
        'DiscMember' => 'decimal:2'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbCUSTSUPPDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}