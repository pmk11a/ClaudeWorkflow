<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSUBJENISBRGJADI extends Model
{
    use HasFactory;

    protected $table = 'DBSUBJENISBRGJADI';
    protected $primaryKey = 'kodesubJnsBrg';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'kodesubJnsBrg', 'Keterangan'
    ];

}
