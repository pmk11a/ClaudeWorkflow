<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJnsInvestasi extends Model
{
    use HasFactory;

    protected $table = 'DBJnsInvestasi';
    protected $primaryKey = 'KODEJnsInvestasi';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEJnsInvestasi', 'NAMAJnsInvestasi', 'TipeInvestasi', 'Perkiraan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbJnsInvestasiDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}