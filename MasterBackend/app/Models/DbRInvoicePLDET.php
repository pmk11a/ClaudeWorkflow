<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbRInvoicePLDET extends Model
{
    use HasFactory;

    protected $table = 'DBRInvoicePLDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'NamaBrg', 'PPN', 'DISC', 'KURS', 'QNT', 'QNT2', 'QNTTukar', 'QNT2Tukar', 'NetW', 'NetWTukar', 'GrossW', 'GrossWTukar', 'Mesurement', 'MesurementTukar', 'SAT_1', 'SAT_2', 'Nosat', 'ISI', 'HARGA', 'DiscP1', 'DiscRp1', 'DiscP2', 'DiscRp2', 'DiscP3', 'DiscRp3', 'DiscP4', 'DiscRp4', 'DISCTOT', 'BYANGKUT', 'HRGNETTO', 'NDISKON', 'SUBTOTAL', 'NDPP', 'NPPN', 'NNET', 'SUBTOTALRp', 'NDPPRp', 'NPPNRp', 'NNETRp', 'NoInvoice', 'UrutInvoice', 'Keterangan', 'UrutTrans', 'HPP', 'MyID', 'NoSPB'
    ];

    protected $casts = [
        'DISC' => 'decimal:2',
        'KURS' => 'decimal:2',
        'QNT' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'QNTTukar' => 'decimal:2',
        'QNT2Tukar' => 'decimal:2',
        'NetW' => 'decimal:2',
        'NetWTukar' => 'decimal:2',
        'GrossW' => 'decimal:2',
        'GrossWTukar' => 'decimal:2',
        'Mesurement' => 'decimal:2',
        'MesurementTukar' => 'decimal:2',
        'ISI' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'DiscP1' => 'decimal:2',
        'DiscRp1' => 'decimal:2',
        'DiscP2' => 'decimal:2',
        'DiscRp2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscRp3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscRp4' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'BYANGKUT' => 'decimal:2',
        'HRGNETTO' => 'decimal:2',
        'NDISKON' => 'decimal:2',
        'SUBTOTAL' => 'decimal:2',
        'NDPP' => 'decimal:2',
        'NPPN' => 'decimal:2',
        'NNET' => 'decimal:2',
        'SUBTOTALRp' => 'decimal:2',
        'NDPPRp' => 'decimal:2',
        'NPPNRp' => 'decimal:2',
        'NNETRp' => 'decimal:2',
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
