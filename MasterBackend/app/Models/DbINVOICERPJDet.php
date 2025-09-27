<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbINVOICERPJDet extends Model
{
    use HasFactory;

    protected $table = 'DBINVOICERPJDet';
    protected $primaryKey = ['NoBukti', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Urut', 'Kodebrg', 'NOSPR', 'UrutSPR', 'Disc', 'PPn', 'Kurs', 'SAT_1', 'SAT_2', 'Qnt', 'Qnt2', 'Nosat', 'Isi', 'Harga', 'DiscP', 'DiscRp', 'DISCTOT', 'HRGNETTO', 'NDISKON', 'SUBTOTAL', 'NDPP', 'NPPN', 'NNET', 'SUBTOTALRp', 'NDPPRp', 'NPPNRp', 'NNETRp', 'Keterangan', 'UrutTrans', 'MyID', 'HPP', 'DiscP2', 'DiscP3', 'DiscP4', 'DiscP5', 'NamaBrg'
    ];

    protected $casts = [
        'Disc' => 'decimal:2',
        'Kurs' => 'decimal:2',
        'Qnt' => 'decimal:2',
        'Qnt2' => 'decimal:2',
        'Harga' => 'decimal:2',
        'DiscP' => 'decimal:2',
        'DiscRp' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'SUBTOTAL' => 'decimal:2',
        'SUBTOTALRp' => 'decimal:2',
        'MyID' => 'datetime',
        'DiscP2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscP5' => 'decimal:2'
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
        return $this->hasMany(DbINVOICERPJDetDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}