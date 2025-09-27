<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTRANSFER extends Model
{
    use HasFactory;

    protected $table = 'DBTRANSFER';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'NOTE', 'IDUSER', 'NoPenyerahan', 'MyID', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
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
    ];


    // Relationships
    public function fromWarehouse()
    {
        return $this->belongsTo(DbGUDANG::class, 'KODEGDG', 'KODEGDG');
    }

    public function toWarehouse()
    {
        return $this->belongsTo(DbGUDANG::class, 'KODEGDGTUJ', 'KODEGDG');
    }

    public function details()
    {
        return $this->hasMany(DbTRANSFERDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}
