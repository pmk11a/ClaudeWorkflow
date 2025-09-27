<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSPBLampiran extends Model
{
    use HasFactory;

    protected $table = 'dbSPBLampiran';
    protected $primaryKey = ['Urut', 'NoSPB', 'UrutSPB'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Urut', 'NoSPB', 'UrutSPB', 'NOPALLET', 'NOROLL', 'NOLOT', 'Sat_1', 'Sat_2', 'Qnt', 'Qnt2', 'Nosat', 'Isi', 'Keterangan', 'NetW', 'GrossW', 'HPP', 'MyID'
    ];

    protected $casts = [
        'Qnt' => 'decimal:2',
        'Qnt2' => 'decimal:2',
        'Isi' => 'decimal:2',
        'NetW' => 'decimal:2',
        'GrossW' => 'decimal:2',
        'HPP' => 'decimal:2',
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
