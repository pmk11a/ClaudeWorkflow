<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbArusKasDet extends Model
{
    use HasFactory;

    protected $table = 'DBArusKasDet';
    protected $primaryKey = 'KodeSubAK';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeSubAK', 'KodeAK', 'NamaSubAK'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbArusKasDetDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}