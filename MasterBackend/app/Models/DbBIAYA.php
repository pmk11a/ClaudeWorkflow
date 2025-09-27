<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBIAYA extends Model
{
    use HasFactory;

    protected $table = 'DBBIAYA';
    protected $primaryKey = 'Kodebiaya';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Kodebiaya', 'Keterangan', 'MyID', 'Perkiraan'
    ];

    protected $casts = [
        'MyID' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbBIAYADET::class, 'NOBUKTI', 'NOBUKTI');
    }

}