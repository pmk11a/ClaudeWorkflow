<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbDATABARANG extends Model
{
    use HasFactory;

    protected $table = 'DBDATABARANG';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEBRG', 'QNTBPPB', 'QNTPB', 'QNTPPL', 'QNTPO', 'QNTPBL', 'QNTRPB', 'QNTPNJ', 'QNTRPJ', 'QNTADI', 'QNTADO', 'QNTUKI', 'QNTUKO', 'QNTTRI', 'QNTTRO', 'QNTOSBPPB', 'QNTOSPPL'
    ];

    protected $casts = [
        'QNTBPPB' => 'decimal:2',
        'QNTPB' => 'decimal:2',
        'QNTPPL' => 'decimal:2',
        'QNTPO' => 'decimal:2',
        'QNTPBL' => 'decimal:2',
        'QNTRPB' => 'decimal:2',
        'QNTPNJ' => 'decimal:2',
        'QNTRPJ' => 'decimal:2',
        'QNTADI' => 'decimal:2',
        'QNTADO' => 'decimal:2',
        'QNTUKI' => 'decimal:2',
        'QNTUKO' => 'decimal:2',
        'QNTTRI' => 'decimal:2',
        'QNTTRO' => 'decimal:2',
        'QNTOSBPPB' => 'decimal:2',
        'QNTOSPPL' => 'decimal:2'
    ];


    // Relationships
    public function item()
    {
        return $this->belongsTo(Dbbarang::class, 'KODEBRG', 'KODEBRG');
    }

    public function details()
    {
        return $this->hasMany(DbDATABARANGDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}