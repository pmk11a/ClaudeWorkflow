<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPenjualan extends Model
{
    use HasFactory;

    protected $table = 'DBPenjualan';
    protected $primaryKey = ['NoBukti', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Urut', 'Tanggal', 'JatuhTempo', 'PPn', 'KodeCustSupp', 'KodeTipe', 'KodeSubTipe', 'Qnt', 'Harga', 'NDPP', 'NPPN', 'NNet', 'AccPersediaan', 'AccPPN', 'AccHutPiut', 'IsExcel', 'KodeVls', 'Kurs', 'NDPPD', 'NPPND', 'NNetD', 'FlagSimbol'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'JatuhTempo' => 'datetime',
        'Qnt' => 'decimal:2',
        'Harga' => 'decimal:2',
        'IsExcel' => 'boolean',
        'Kurs' => 'decimal:2'
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
        return $this->hasMany(DbPenjualanDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}