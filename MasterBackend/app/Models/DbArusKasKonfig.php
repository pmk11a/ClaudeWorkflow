<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbArusKasKonfig extends Model
{
    use HasFactory;

    protected $table = 'DBArusKasKonfig';
    protected $primaryKey = 'Nomor';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeAK', 'KodeSAK', 'Tipe', 'Keterangan', 'Nomor', 'Urutan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbArusKasKonfigDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}