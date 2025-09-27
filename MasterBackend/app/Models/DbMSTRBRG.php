<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbMSTRBRG extends Model
{
    use HasFactory;

    protected $table = 'DBMSTRBRG';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODE', 'KETERANGAN', 'SAT', 'HARGA'
    ];

    protected $casts = [
        'HARGA' => 'decimal:2',
    ];

}
