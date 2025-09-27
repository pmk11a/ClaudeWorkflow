<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbGROUP extends Model
{
    use HasFactory;

    protected $table = 'DBGROUP';
    protected $primaryKey = 'KODEGRP';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEGRP', 'NAMA'
    ];



    // Relationships
    public function group()
    {
        return $this->belongsTo(DbGROUP::class, 'KODEGRP', 'KODEGRP');
    }

    public function details()
    {
        return $this->hasMany(DbGROUPDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}