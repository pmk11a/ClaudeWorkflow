<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSURATJLNDET extends Model
{
    use HasFactory;

    protected $table = 'DBSURATJLNDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'KODEGDG', 'QNT', 'QNT2', 'QNTBATAL', 'TGLBATAL', 'NOSAT', 'SATUAN', 'ISI', 'HARGA', 'HPP', 'URUTSPP', 'NOSPP', 'KetDet', 'NetW', 'GrossW'
    ];

    protected $casts = [
        'QNT' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'QNTBATAL' => 'decimal:2',
        'TGLBATAL' => 'datetime',
        'ISI' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'HPP' => 'decimal:2',
        'NetW' => 'decimal:2',
        'GrossW' => 'decimal:2',
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
