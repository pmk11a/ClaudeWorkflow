<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbDATA extends Model
{
    use HasFactory;

    protected $table = 'DBDATA';
    protected $primaryKey = 'KODEDATA';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODETAB', 'KODEDATA', 'Nama'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbDATADET::class, 'NOBUKTI', 'NOBUKTI');
    }

}