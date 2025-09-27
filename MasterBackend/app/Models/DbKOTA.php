<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKOTA extends Model
{
    use HasFactory;

    protected $table = 'DBKOTA';
    protected $primaryKey = 'KodeKota';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeKota', 'NamaKota', 'KodeArea'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbKOTADET::class, 'NOBUKTI', 'NOBUKTI');
    }

}