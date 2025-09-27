<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSUBKATEGORIBRGJADI extends Model
{
    use HasFactory;

    protected $table = 'DBSUBKATEGORIBRGJADI';
    protected $primaryKey = 'KodeSubKategori';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeSubKategori', 'Keterangan'
    ];

}
