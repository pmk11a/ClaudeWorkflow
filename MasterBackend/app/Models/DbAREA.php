<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbAREA extends Model
{
    use HasFactory;

    protected $table = 'DBAREA';
    protected $primaryKey = 'KODEAREA';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEAREA', 'NAMAAREA'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbAREADET::class, 'NOBUKTI', 'NOBUKTI');
    }

}