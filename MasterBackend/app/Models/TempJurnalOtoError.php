<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempJurnalOtoError extends Model
{
    use HasFactory;

    protected $table = 'TempJurnalOtoError';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'IDUser', 'Urut', 'JurnalOrHP', 'JenisTrans', 'NoBuktiTrans', 'NoBukti', 'Perkiraan', 'Lawan'
    ];

}
