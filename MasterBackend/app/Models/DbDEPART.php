<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbDEPART extends Model
{
    use HasFactory;

    protected $table = 'DBDEPART';
    protected $primaryKey = 'KDDEP';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KDDEP', 'NMDEP', 'PerkBiaya'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbDEPARTDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}