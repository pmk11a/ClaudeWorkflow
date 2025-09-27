<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKirimDET extends Model
{
    use HasFactory;

    protected $table = 'DBKirimDET';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'KodeBrg', 'NamaBrg', 'NoSat', 'Urut', 'Tanggal', 'Qnt'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'Qnt' => 'decimal:2'
    ];


    // Relationships
    public function header()
    {
        return $this->belongsTo(DbKirim::class, 'NOBUKTI', 'NOBUKTI');
    }

}