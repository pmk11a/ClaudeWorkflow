<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPERKCOST extends Model
{
    use HasFactory;

    protected $table = 'DBPERKCOST';
    protected $primaryKey = 'Perkiraan';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeCost', 'Urut', 'Perkiraan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbPERKCOSTDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}