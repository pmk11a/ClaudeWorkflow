<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBiayaStdCost extends Model
{
    use HasFactory;

    protected $table = 'dbBiayaStdCost';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeSetting', 'KodeBrg', 'Harga'
    ];

    protected $casts = [
        'Harga' => 'decimal:2'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbBiayaStdCostDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}