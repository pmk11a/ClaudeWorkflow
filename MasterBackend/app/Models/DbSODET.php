<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSODET extends Model
{
    use HasFactory;

    protected $table = 'DBSODET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'TGLKIRIM', 'PPN', 'DISC', 'KURS', 'QNT', 'QNT2', 'QNTBATAL', 'TGLBATAL', 'NOSAT', 'SATUAN', 'ISI', 'HARGA', 'HPP', 'DISCP1', 'DISCRP1', 'DISCTOT', 'BYANGKUT', 'HRGNETTO', 'NDISKON', 'SUBTOTAL', 'NDPP', 'NPPN', 'NNET', 'SUBTOTALRp', 'NDPPRp', 'NPPNRp', 'NNETRp', 'NOSPB', 'UrutSPB', 'Qnt3', 'QntSisaSO', 'Qnt2SisaSO', 'QntSJln', 'Qnt2SJln', 'IsCetakKitir', 'DiscP2', 'DiscP3', 'DiscP4', 'DiscP5', 'IsCloseDet'
    ];

    protected $casts = [
        'TGLKIRIM' => 'datetime',
        'DISC' => 'decimal:2',
        'KURS' => 'decimal:2',
        'QNT' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'QNTBATAL' => 'decimal:2',
        'TGLBATAL' => 'datetime',
        'ISI' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'HPP' => 'decimal:2',
        'DISCP1' => 'decimal:2',
        'DISCRP1' => 'decimal:2',
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
        'Qnt3' => 'decimal:2',
        'QntSisaSO' => 'decimal:2',
        'Qnt2SisaSO' => 'decimal:2',
        'QntSJln' => 'decimal:2',
        'Qnt2SJln' => 'decimal:2',
        'IsCetakKitir' => 'boolean',
        'DiscP2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscP5' => 'decimal:2',
        'IsCloseDet' => 'boolean',
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
