<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKELOMPOK extends Model
{
    use HasFactory;

    protected $table = 'DBKELOMPOK';
    protected $primaryKey = 'KodeKelompok';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeKelompok', 'Keterangan', 'Perkiraan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbKELOMPOKDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}