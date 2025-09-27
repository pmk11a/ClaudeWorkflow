<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbMENUDASBOARD extends Model
{
    use HasFactory;

    protected $table = 'DBMENUDASBOARD';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'UserID', 'L0', 'L1', 'NmReport', 'KodeReport', 'Access'
    ];

}
