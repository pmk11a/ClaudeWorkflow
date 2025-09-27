<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKATEGORIBRGJADI extends Model
{
    use HasFactory;

    protected $table = 'DBKATEGORIBRGJADI';
    protected $primaryKey = 'KodeKategori';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeKategori', 'Keterangan', 'Kodegdg', 'Perkiraan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbKATEGORIBRGJADIDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}