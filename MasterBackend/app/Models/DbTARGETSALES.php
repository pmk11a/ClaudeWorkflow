<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTARGETSALES extends Model
{
    use HasFactory;

    protected $table = 'DBTARGETSALES';
    protected $primaryKey = ['KeyNik', 'Tahun'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KeyNik', 'Tahun', 'Rp1', 'Rp2', 'Rp3', 'Rp4', 'Rp5', 'Rp6', 'Rp7', 'Rp8', 'Rp9', 'Rp10', 'Rp11', 'Rp12', 'QNT1', 'QNT2', 'QNT3', 'QNT4', 'QNT5', 'QNT6', 'QNT7', 'QNT8', 'QNT9', 'QNT10', 'QNT11', 'QNT12'
    ];

    protected $casts = [
        'Rp1' => 'decimal:2',
        'Rp2' => 'decimal:2',
        'Rp3' => 'decimal:2',
        'Rp4' => 'decimal:2',
        'Rp5' => 'decimal:2',
        'Rp6' => 'decimal:2',
        'Rp7' => 'decimal:2',
        'Rp8' => 'decimal:2',
        'Rp9' => 'decimal:2',
        'Rp10' => 'decimal:2',
        'Rp11' => 'decimal:2',
        'Rp12' => 'decimal:2',
        'QNT1' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'QNT3' => 'decimal:2',
        'QNT4' => 'decimal:2',
        'QNT5' => 'decimal:2',
        'QNT6' => 'decimal:2',
        'QNT7' => 'decimal:2',
        'QNT8' => 'decimal:2',
        'QNT9' => 'decimal:2',
        'QNT10' => 'decimal:2',
        'QNT11' => 'decimal:2',
        'QNT12' => 'decimal:2',
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
