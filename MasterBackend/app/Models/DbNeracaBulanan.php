<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbNeracaBulanan extends Model
{
    use HasFactory;

    protected $table = 'DBNeracaBulanan';
    protected $primaryKey = 'Perkiraan';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Keterangan', 'DK', 'GroupPerkiraan', 'IsSubPerkiraan', 'Tanda'
    ];

    protected $casts = [
        'IsSubPerkiraan' => 'boolean'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbNeracaBulananDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}