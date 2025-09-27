<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJABATAN extends Model
{
    use HasFactory;

    protected $table = 'DBJABATAN';
    protected $primaryKey = 'KODEJAB';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEJAB', 'NamaJab', 'MyID'
    ];

    protected $casts = [
        'MyID' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbJABATANDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}