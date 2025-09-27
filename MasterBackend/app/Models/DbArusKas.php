<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbArusKas extends Model
{
    use HasFactory;

    protected $table = 'DBArusKas';
    protected $primaryKey = 'KodeAK';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeAK', 'NamaAK'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbArusKasDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}