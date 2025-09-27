<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPODET extends Model
{
    use HasFactory;

    protected $table = 'DBPODET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'NamaBrg', 'PPN', 'KURS', 'DISC', 'QNT', 'QntBatal', 'TglBatal', 'NOSAT', 'SATUAN', 'ISI', 'HARGA', 'DISCP', 'DISCTOT', 'BYANGKUT', 'HRGNETTO', 'NDISKON', 'SUBTOTAL', 'NDPP', 'NPPN', 'NNET', 'SUBTOTALRp', 'NDPPRp', 'NPPNRp', 'NNETRp', 'NoPPL', 'UrutPPL', 'IsClose', 'Tolerate', 'DiscP2', 'DiscP3', 'DiscP4', 'DiscP5', 'Isbatal', 'UserBatal', 'Isjasa'
    ];

    protected $casts = [
        'KURS' => 'decimal:2',
        'QNT' => 'decimal:2',
        'QntBatal' => 'decimal:2',
        'TglBatal' => 'datetime',
        'HARGA' => 'decimal:2',
        'DISCP' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'SUBTOTAL' => 'decimal:2',
        'SUBTOTALRp' => 'decimal:2',
        'IsClose' => 'boolean',
        'DiscP2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscP5' => 'decimal:2',
        'Isbatal' => 'boolean',
        'Isjasa' => 'boolean'
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
        return $this->belongsTo(DbPO::class, 'NOBUKTI', 'NOBUKTI');
    }

}