<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbNomorFP extends Model
{
    use HasFactory;

    protected $table = 'DBNomorFP';
    protected $primaryKey = 'Kode';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Kode', 'NoAwal', 'NoAkhir', 'IsPenuh', 'NoSeri'
    ];

    protected $casts = [
        'IsPenuh' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbNomorFPDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}