<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbDEPOSITO extends Model
{
    use HasFactory;

    protected $table = 'DBDEPOSITO';
    protected $primaryKey = ['NoDEPOSITO', 'Bank', 'Tipe'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoDEPOSITO', 'Bank', 'Tanggal', 'TglJatuhTempo', 'Debet', 'Kredit', 'DebetRp', 'KreditRp', 'Keterangan', 'TglBuka', 'BuktiBuka', 'UrutBuktiBuka', 'TglCair', 'BuktiCair', 'KeteranganCair', 'UrutBuktiCair', 'Kodevls', 'Kurs', 'Jumlah', 'Tipe', 'MyID'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'TglJatuhTempo' => 'datetime',
        'TglBuka' => 'datetime',
        'TglCair' => 'datetime',
        'Kurs' => 'decimal:2',
        'Jumlah' => 'decimal:2',
        'MyID' => 'datetime'
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
        return $this->hasMany(DbDEPOSITODET::class, 'NOBUKTI', 'NOBUKTI');
    }

}