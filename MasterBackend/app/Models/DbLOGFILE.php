<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbLOGFILE extends Model
{
    use HasFactory;

    protected $table = 'DBLOGFILE';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Tahun', 'Bulan', 'Tanggal', 'Pemakai', 'Aktivitas', 'Sumber', 'NoBukti', 'Keterangan'
    ];

    protected $casts = [
        'Tanggal' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbLOGFILEDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}