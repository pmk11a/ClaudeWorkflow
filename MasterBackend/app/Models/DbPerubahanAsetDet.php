<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPerubahanAsetDet extends Model
{
    use HasFactory;

    protected $table = 'DBPerubahanAsetDet';
    protected $primaryKey = 'KodeSubPAN';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeSubPAN', 'KodePAN', 'NamaSubPAN'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbPerubahanAsetDetDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}