<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPERKCUSTSUPP extends Model
{
    use HasFactory;

    protected $table = 'DBPERKCUSTSUPP';
    protected $primaryKey = 'KODECUSTSUPP';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeCustSupp', 'Urut', 'Perkiraan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbPERKCUSTSUPPDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}