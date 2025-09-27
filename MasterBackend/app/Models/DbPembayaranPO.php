<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPembayaranPO extends Model
{
    use HasFactory;

    protected $table = 'DBPembayaranPO';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Keterangan', 'DP', 'Persentase', 'KodeVls', 'Nilai'
    ];

    protected $casts = [
        'DP' => 'boolean',
        'Nilai' => 'decimal:2'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbPembayaranPODET::class, 'NOBUKTI', 'NOBUKTI');
    }

}