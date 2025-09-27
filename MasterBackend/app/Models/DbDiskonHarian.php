<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbDiskonHarian extends Model
{
    use HasFactory;

    protected $table = 'DBDiskonHarian';
    protected $primaryKey = 'Hari';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Hari', 'Diskon', 'Aktif'
    ];

    protected $casts = [
        'Aktif' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbDiskonHarianDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}