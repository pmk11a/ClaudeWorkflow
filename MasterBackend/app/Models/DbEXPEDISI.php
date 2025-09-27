<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbEXPEDISI extends Model
{
    use HasFactory;

    protected $table = 'DBEXPEDISI';
    protected $primaryKey = 'KODEEXP';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEEXP', 'NAMAEXP', 'ALAMAT1', 'ALAMAT2', 'KOTA', 'KODEPOS', 'TELPON', 'HP', 'FAX', 'EMAIL', 'Contact', 'Perkiraan', 'Aktif'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbEXPEDISIDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}