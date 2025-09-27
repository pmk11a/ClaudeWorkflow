<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKATEGORI extends Model
{
    use HasFactory;

    protected $table = 'DBKATEGORI';
    protected $primaryKey = 'KodeKategori';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeKategori', 'Keterangan', 'Kodegdg'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbKATEGORIDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}