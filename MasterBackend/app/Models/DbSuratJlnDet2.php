<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSuratJlnDet2 extends Model
{
    use HasFactory;

    protected $table = 'dbSuratJlnDet2';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Urut', 'Qnt', 'Satuan', 'Isi'
    ];

    protected $casts = [
        'Qnt' => 'decimal:2',
        'Isi' => 'decimal:2',
    ];

}
