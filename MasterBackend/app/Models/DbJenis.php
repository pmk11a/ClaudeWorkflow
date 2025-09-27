<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJenis extends Model
{
    use HasFactory;

    protected $table = 'DBJenis';
    protected $primaryKey = 'KodeJnsBrg';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeJnsBrg', 'Keterangan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbJenisDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}