<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbRBELIDET extends Model
{
    use HasFactory;

    protected $table = 'DBRBELIDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'NamaBrg', 'PPN', 'KURS', 'DISC', 'QNT', 'NOSAT', 'SATUAN', 'ISI', 'HARGA', 'DISCP', 'DISCTOT', 'BYANGKUT', 'NOPBL', 'URUTPBL', 'Qnt2', 'Qnt1', 'HPP', 'HRGNETTO', 'NDISKON', 'SUBTOTAL', 'NDPP', 'NPPN', 'NNET', 'SUBTOTALRp', 'NDPPRp', 'NPPNRp', 'NNETRp', 'DiscP2', 'DiscP3', 'DiscP4', 'DiscP5', 'Isjasa', 'NOBATCH'
    ];

    protected $casts = [
        'KURS' => 'decimal:2',
        'QNT' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'DISCP' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'Qnt2' => 'decimal:2',
        'Qnt1' => 'decimal:2',
        'SUBTOTAL' => 'decimal:2',
        'SUBTOTALRp' => 'decimal:2',
        'DiscP2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscP5' => 'decimal:2',
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
        return $this->belongsTo(DbRBELI::class, 'NOBUKTI', 'NOBUKTI');
    }

}