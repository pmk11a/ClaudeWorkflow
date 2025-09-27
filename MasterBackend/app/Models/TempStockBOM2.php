<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempStockBOM2 extends Model
{
    use HasFactory;

    protected $table = 'TempStockBOM2';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'IDUser', 'KodeBrg', 'KodeBOM', 'StrLevelBOM', 'IntLevelBOM', 'Urut1', 'Urut2', 'QntBOM_', 'QntBOMX', 'QntBOM', 'IsBarang', 'QntStockR', 'QntOutPO', 'QntOutPrd', 'QntOutSPK', 'QntStock', 'QntSisaStock', 'QntProduksi'
    ];

    protected $casts = [
        'QntBOM_' => 'decimal:2',
        'QntBOMX' => 'decimal:2',
        'QntBOM' => 'decimal:2',
        'QntStockR' => 'decimal:2',
        'QntOutPO' => 'decimal:2',
        'QntOutPrd' => 'decimal:2',
        'QntOutSPK' => 'decimal:2',
        'QntStock' => 'decimal:2',
        'QntSisaStock' => 'decimal:2',
        'QntProduksi' => 'decimal:2',
    ];

}
