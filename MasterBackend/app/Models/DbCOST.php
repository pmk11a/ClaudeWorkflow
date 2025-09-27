<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbCOST extends Model
{
    use HasFactory;

    protected $table = 'DBCOST';
    protected $primaryKey = 'KodeCost';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeCost', 'NamaCost'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbCOSTDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}