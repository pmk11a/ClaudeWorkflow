<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKENDARAAN extends Model
{
    use HasFactory;

    protected $table = 'DBKENDARAAN';
    protected $primaryKey = 'KODEKEND';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEKEND', 'KODEJENISKEND', 'NAMAKEND', 'NOCHASIS', 'MERKKEND', 'IsAktif', 'KodeCost'
    ];

    protected $casts = [
        'IsAktif' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbKENDARAANDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}