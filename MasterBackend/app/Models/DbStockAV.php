<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbStockAV extends Model
{
    use HasFactory;

    protected $table = 'DBStockAV';
    protected $primaryKey = ['Bulan', 'Tahun', 'Kodebrg', 'Kodegdg'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Bulan', 'Tahun', 'Kodebrg', 'Kodegdg', 'QntAwal', 'Qnt2Awal', 'QntIN', 'Qnt2IN', 'QntOut', 'Qnt2Out', 'QntSPP', 'Qnt2SPP', 'SaldoQnt', 'Saldo2Qnt'
    ];

    protected $casts = [
        'QntAwal' => 'decimal:2',
        'Qnt2Awal' => 'decimal:2',
        'QntIN' => 'decimal:2',
        'Qnt2IN' => 'decimal:2',
        'QntOut' => 'decimal:2',
        'Qnt2Out' => 'decimal:2',
        'QntSPP' => 'decimal:2',
        'Qnt2SPP' => 'decimal:2',
        'SaldoQnt' => 'decimal:2',
        'Saldo2Qnt' => 'decimal:2',
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
