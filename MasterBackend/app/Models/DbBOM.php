<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBOM extends Model
{
    use HasFactory;

    protected $table = 'DBBOM';
    protected $primaryKey = 'KodeBOM';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeBOM', 'KodeBrg', 'NoUrut', 'IsDefault', 'TglAwal', 'TglAkhir'
    ];

    protected $casts = [
        'IsDefault' => 'boolean',
        'TglAwal' => 'datetime',
        'TglAkhir' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbBOMDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}