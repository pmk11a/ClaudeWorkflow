<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbInvoicePLLampiran extends Model
{
    use HasFactory;

    protected $table = 'DBInvoicePLLampiran';
    protected $primaryKey = ['Nobukti', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Nobukti', 'Urut', 'Keterangan', 'KodeVls', 'Kurs', 'Qnt', 'Qnt2', 'Nosat', 'Sat_1', 'Sat_2', 'Harga', 'NNet', 'NNetRp'
    ];

    protected $casts = [
        'Kurs' => 'decimal:2',
        'Qnt' => 'decimal:2',
        'Qnt2' => 'decimal:2',
        'Harga' => 'decimal:2'
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

    // Relationships
    public function details()
    {
        return $this->hasMany(DbInvoicePLLampiranDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}