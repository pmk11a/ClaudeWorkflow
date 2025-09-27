<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbUBAHKEMASANDET extends Model
{
    use HasFactory;

    protected $table = 'DBUBAHKEMASANDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'KodeGdg', 'SATUAN', 'NOSAT', 'ISI', 'QNTDB', 'QNTCR', 'HARGA', 'HPP', 'HPP2', 'QntPRSI', 'QntPRSO', 'HrgPRSI', 'HrgPRSO', 'HargaIn', 'tglInput', 'UserID'
    ];

    protected $casts = [
        'ISI' => 'decimal:2',
        'QNTDB' => 'decimal:2',
        'QNTCR' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'HPP' => 'decimal:2',
        'HPP2' => 'decimal:2',
        'QntPRSI' => 'decimal:2',
        'QntPRSO' => 'decimal:2',
        'HrgPRSI' => 'decimal:2',
        'HrgPRSO' => 'decimal:2',
        'HargaIn' => 'decimal:2',
        'tglInput' => 'datetime',
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
