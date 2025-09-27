<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbMENU extends Model
{
    use HasFactory;

    protected $table = 'DBMENU';
    protected $primaryKey = 'KODEMENU';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEMENU', 'Keterangan', 'L0', 'ACCESS', 'OL', 'TipeTrans', 'icon', 'routename'
    ];



    // Relationships
    public function userPermissions()
    {
        return $this->hasMany(DbFLMENU::class, 'L1', 'KODEMENU');
    }

    // Get all users who have access to this menu
    public function authorizedUsers()
    {
        return $this->hasManyThrough(
            DbFLPASS::class,
            DbFLMENU::class,
            'L1', // Foreign key on DbFLMENU table
            'USERID', // Foreign key on DbFLPASS table
            'KODEMENU', // Local key on DbMENU table
            'USERID' // Local key on DbFLMENU table
        )->where('HASACCESS', 1);
    }

    // Scopes
    public function scopeByLevel($query, $level)
    {
        return $query->where('L0', $level);
    }

    public function scopeAccessible($query)
    {
        return $query->where('ACCESS', 1);
    }

}