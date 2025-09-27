<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbInvoicePLDet extends Model
{
    use HasFactory;

    protected $table = 'dbInvoicePLDet';
    protected $primaryKey = ['NoBukti', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Urut', 'NoSPB', 'UrutSPB', 'KodeBrg', 'Namabrg', 'ShippingMark', 'PPN', 'DISC', 'KURS', 'QNT', 'QNT2', 'SAT_1', 'SAT_2', 'NOSAT', 'ISI', 'NetW', 'GrossW', 'Meas', 'HARGA', 'DiscP', 'DiscRp', 'DISCTOT', 'HrgNetto', 'NDISKON', 'SUBTOTAL', 'NDISKONRp', 'SUBTOTALRp', 'KetDetail', 'MyID', 'HPP', 'NoSPP', 'TGLSPP', 'NoSO', 'TGLSO', 'PoNO', 'UrutTrans', 'DiscP2', 'DiscP3', 'DiscP4', 'DiscP5', 'NOBatch', 'Usercetak', 'TglCetak', 'PPnP', 'NDPP', 'NPPN', 'NNET', 'NDPPRp', 'NPPNRp', 'NNETRp'
    ];

    protected $casts = [
        'DISC' => 'decimal:2',
        'KURS' => 'decimal:2',
        'QNT' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'DiscP' => 'decimal:2',
        'DiscRp' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'SUBTOTAL' => 'decimal:2',
        'SUBTOTALRp' => 'decimal:2',
        'MyID' => 'datetime',
        'TGLSPP' => 'datetime',
        'TGLSO' => 'datetime',
        'DiscP2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscP5' => 'decimal:2',
        'TglCetak' => 'datetime'
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
        return $this->hasMany(DbInvoicePLDetDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}