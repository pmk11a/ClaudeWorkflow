<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPerubahanAset extends Model
{
    use HasFactory;

    protected $table = 'DBPerubahanAset';
    protected $primaryKey = 'KodePAN';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodePAN', 'NamaPAN'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbPerubahanAsetDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}