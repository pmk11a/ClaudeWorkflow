<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbNOMORPK extends Model
{
    use HasFactory;

    protected $table = 'DBNOMORPK';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Tipe', 'NOURUT', 'NOBUKTI', 'USERID', 'Bulan', 'Tahun', 'flagtipe'
    ];

    protected $casts = [
        'flagtipe' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbNOMORPKDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}