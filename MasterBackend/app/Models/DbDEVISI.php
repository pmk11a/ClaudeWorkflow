<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbDEVISI extends Model
{
    use HasFactory;

    protected $table = 'DBDEVISI';
    protected $primaryKey = 'Devisi';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Devisi', 'NamaDevisi', 'MyID'
    ];

    protected $casts = [
        'MyID' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbDEVISIDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}