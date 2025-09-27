<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKaryawan extends Model
{
    use HasFactory;

    protected $table = 'dbKaryawan';
    protected $primaryKey = 'KeyNIK';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KeyNIK', 'TipeTrans', 'NoBukti', 'NIK', 'Nama', 'NamaPanggilan', 'Kelamin', 'TmpLahir', 'TglLahir', 'Agama', 'Tinggi', 'Berat', 'BerkacaMata', 'Darah', 'NomorKTP', 'AlamatKTP', 'KecamatanKTP', 'KabupatenKTP', 'PropinsiKTP', 'KodePosKTP', 'AlamatRmh', 'KecamatanRmh', 'KabupatenRmh', 'PropinsiRmh', 'KodePosRmh', 'TeleponHP', 'KodePendAkhir', 'KetPendAkhir', 'StatusTempTinggal', 'Hubungan', 'Referensi', 'Rekomendasi', 'NamaR', 'JabatanR', 'NamaInstR', 'AlamatR', 'TglMasuk', 'TglKeluar', 'BankAccount', 'NomorAstek', 'TglAstek', 'KodeShf', 'KodeJab', 'KodeDept', 'KodeESL', 'KodeGrade', 'GajiPokok', 'TnjJabatan', 'TnjKehadiran', 'TnjTransport', 'TnjMakan', 'TnjLain2', 'TnjHaid', 'JKK', 'JHT', 'JPK', 'JKM', 'Prima', 'TnjPajak', 'StsPJK', 'StsAST', 'Tanggung', 'NPWP', 'Aktif', 'LamaKontrak', 'TglAkhirKontrak', 'IDUserInput', 'TglInput', 'IsSales', 'Produksi', 'KodeGdg', 'KodeCost'
    ];

    protected $casts = [
        'TglLahir' => 'datetime',
        'TglMasuk' => 'datetime',
        'TglKeluar' => 'datetime',
        'TglAstek' => 'datetime',
        'TnjPajak' => 'boolean',
        'Aktif' => 'boolean',
        'TglAkhirKontrak' => 'datetime',
        'TglInput' => 'datetime',
        'IsSales' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbKaryawanDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}