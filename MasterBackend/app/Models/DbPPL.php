<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPPL extends Model
{
    use HasFactory;

    protected $table = 'DBPPL';
    protected $primaryKey = 'Nobukti';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Nobukti', 'Nourut', 'Tanggal', 'IsClose', 'KDDep', 'cetakke', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL', 'IsBatal', 'UserBatal', 'TglBatal'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'IsClose' => 'boolean',
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
        'IsBatal' => 'boolean',
        'TglBatal' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbPPLDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}