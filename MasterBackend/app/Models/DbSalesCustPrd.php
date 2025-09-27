<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSalesCustPrd extends Model
{
    use HasFactory;

    protected $table = 'DBSalesCustPrd';
    protected $primaryKey = ['KodeCustSupp', 'KodeSLS', 'KodeBrg', 'Tahun'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeCustSupp', 'KodeSLS', 'KodeBrg', 'Tahun', 'QntBln1', 'Qnt2Bln1', 'RpBln1', 'QntBln2', 'Qnt2Bln2', 'RpBln2', 'QntBln3', 'Qnt2Bln3', 'RpBln3', 'QntBln4', 'Qnt2Bln4', 'RpBln4', 'QntBln5', 'Qnt2Bln5', 'RpBln5', 'QntBln6', 'Qnt2Bln6', 'RpBln6', 'QntBln7', 'Qnt2Bln7', 'RpBln7', 'QntBln8', 'Qnt2Bln8', 'RpBln8', 'QntBln9', 'Qnt2Bln9', 'RpBln9', 'QntBln10', 'Qnt2Bln10', 'RpBln10', 'QntBln11', 'Qnt2Bln11', 'RpBln11', 'QntBln12', 'Qnt2Bln12', 'RpBln12'
    ];

    protected $casts = [
        'QntBln1' => 'decimal:2',
        'Qnt2Bln1' => 'decimal:2',
        'RpBln1' => 'decimal:2',
        'QntBln2' => 'decimal:2',
        'Qnt2Bln2' => 'decimal:2',
        'RpBln2' => 'decimal:2',
        'QntBln3' => 'decimal:2',
        'Qnt2Bln3' => 'decimal:2',
        'RpBln3' => 'decimal:2',
        'QntBln4' => 'decimal:2',
        'Qnt2Bln4' => 'decimal:2',
        'RpBln4' => 'decimal:2',
        'QntBln5' => 'decimal:2',
        'Qnt2Bln5' => 'decimal:2',
        'RpBln5' => 'decimal:2',
        'QntBln6' => 'decimal:2',
        'Qnt2Bln6' => 'decimal:2',
        'RpBln6' => 'decimal:2',
        'QntBln7' => 'decimal:2',
        'Qnt2Bln7' => 'decimal:2',
        'RpBln7' => 'decimal:2',
        'QntBln8' => 'decimal:2',
        'Qnt2Bln8' => 'decimal:2',
        'RpBln8' => 'decimal:2',
        'QntBln9' => 'decimal:2',
        'Qnt2Bln9' => 'decimal:2',
        'RpBln9' => 'decimal:2',
        'QntBln10' => 'decimal:2',
        'Qnt2Bln10' => 'decimal:2',
        'RpBln10' => 'decimal:2',
        'QntBln11' => 'decimal:2',
        'Qnt2Bln11' => 'decimal:2',
        'RpBln11' => 'decimal:2',
        'QntBln12' => 'decimal:2',
        'Qnt2Bln12' => 'decimal:2',
        'RpBln12' => 'decimal:2',
    ];

    // Composite primary key support
    protected function setKeysForSaveQuery($query)
    {
        $keys = $this->getKeyName();
        if(!is_array($keys)){
            return parent::setKeysForSaveQuery($query);
        }

        foreach($keys as $keyName){
            $query->where($keyName, '=', $this->getKeyForSaveQuery($keyName));
        }

        return $query;
    }

    protected function getKeyForSaveQuery($keyName = null)
    {
        if(is_null($keyName)){
            $keyName = $this->getKeyName();
        }

        if (isset($this->original[$keyName])) {
            return $this->original[$keyName];
        }

        return $this->getAttribute($keyName);
    }

}
