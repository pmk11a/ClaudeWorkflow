<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbMERK extends Model
{
    use HasFactory;

    protected $table = 'DBMERK';
    protected $primaryKey = 'KODEMERK';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEMERK', 'NAMAMERK'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbMERKDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}