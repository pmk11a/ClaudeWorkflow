<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbMENUREPORT extends Model
{
    use HasFactory;

    protected $table = 'DBMENUREPORT';
    protected $primaryKey = 'KODEMENU';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEMENU', 'Keterangan', 'L0', 'ACCESS', 'OL'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbMENUREPORTDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}