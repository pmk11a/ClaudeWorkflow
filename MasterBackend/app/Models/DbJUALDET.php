<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJUALDET extends Model
{
    use HasFactory;

    protected $table = 'DBJUALDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'KODEGDG', 'TGLKIRIM', 'PPN', 'DISC', 'KURS', 'QNT', 'QNT2', 'QNTBATAL', 'TGLBATAL', 'NOSAT', 'SATUAN', 'ISI', 'HARGA', 'HPP', 'DISCP1', 'DISCRp1', 'DISCTOT', 'BYANGKUT', 'NOSO', 'URUTSO', 'NOSJLN', 'URUTSJLN', 'HRGNETTO', 'NDISKON', 'SUBTOTAL', 'NDPP', 'NPPN', 'NNET', 'SUBTOTALRp', 'NDPPRp', 'NPPNRp', 'NNETRp', 'NetW', 'GrossW'
    ];

    protected $casts = [
        'TGLKIRIM' => 'datetime',
        'KURS' => 'decimal:2',
        'QNT' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'QNTBATAL' => 'decimal:2',
        'TGLBATAL' => 'datetime',
        'HARGA' => 'decimal:2',
        'DISCP1' => 'decimal:2',
        'DISCRp1' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'SUBTOTAL' => 'decimal:2',
        'SUBTOTALRp' => 'decimal:2'
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
    public function item()
    {
        return $this->belongsTo(Dbbarang::class, 'KODEBRG', 'KODEBRG');
    }

    public function header()
    {
        return $this->belongsTo(DbJUAL::class, 'NOBUKTI', 'NOBUKTI');
    }

}