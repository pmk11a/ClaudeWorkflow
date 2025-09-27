<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPerubahanAsetKonfig extends Model
{
    use HasFactory;

    protected $table = 'DBPerubahanAsetKonfig';
    protected $primaryKey = 'Nomor';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodePAN', 'KodeSubPAN', 'Tipe', 'Keterangan', 'Nomor', 'Urutan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbPerubahanAsetKonfigDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}