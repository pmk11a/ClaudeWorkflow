<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbCUSTOMIZE extends Model
{
    use HasFactory;

    protected $table = 'DBCUSTOMIZE';
    protected $primaryKey = 'ID';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'ID', 'IDuser', 'Tipe'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbCUSTOMIZEDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}