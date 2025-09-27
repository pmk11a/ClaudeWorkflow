<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbGUDANG extends Model
{
    use HasFactory;

    protected $table = 'DBGUDANG';
    protected $primaryKey = 'KODEGDG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEGDG', 'NAMA', 'IsRusak', 'Alamat', 'IsCust', 'MyID', 'FlagMenu', 'IsProduksi', 'istakeinout'
    ];

    protected $casts = [
        'IsRusak' => 'boolean',
        'IsCust' => 'boolean',
        'MyID' => 'datetime',
        'IsProduksi' => 'boolean',
        'istakeinout' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbGUDANGDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}