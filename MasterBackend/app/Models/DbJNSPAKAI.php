<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJNSPAKAI extends Model
{
    use HasFactory;

    protected $table = 'DBJNSPAKAI';
    protected $primaryKey = 'KodeJNSPakai';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeJNSPakai', 'Keterangan', 'Perkiraan'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbJNSPAKAIDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}