<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJNSTambahan extends Model
{
    use HasFactory;

    protected $table = 'DBJNSTambahan';
    protected $primaryKey = 'KodeJnsTambahan';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeJnsTambahan', 'NAMA'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbJNSTambahanDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}