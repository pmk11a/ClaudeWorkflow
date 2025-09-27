<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJBAHAN extends Model
{
    use HasFactory;

    protected $table = 'DBJBAHAN';
    protected $primaryKey = 'KDBHN';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KDBHN', 'NAMABHN'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbJBAHANDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}