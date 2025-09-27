<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSPBDet extends Model
{
    use HasFactory;

    protected $table = 'dbSPBDet';
    protected $primaryKey = ['NoBukti', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Urut', 'NoSPP', 'UrutSPP', 'KodeBrg', 'Namabrg', 'QNT', 'QNT2', 'SAT_1', 'SAT_2', 'NOSAT', 'ISI', 'NetW', 'GrossW', 'HPP', 'KodeGdg', 'isCetakKitir', 'NOBatch'
    ];

    protected $casts = [
        'QNT' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'ISI' => 'decimal:2',
        'NetW' => 'decimal:2',
        'GrossW' => 'decimal:2',
        'HPP' => 'decimal:2',
        'isCetakKitir' => 'boolean',
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
