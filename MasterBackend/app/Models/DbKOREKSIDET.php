<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKOREKSIDET extends Model
{
    use HasFactory;

    protected $table = 'DBKOREKSIDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'KODEGDG', 'SATUAN', 'NOSAT', 'ISI', 'SaldoComp', 'QntOpname', 'Selisih', 'QNTDB', 'QNTCR', 'HARGA', 'HPP', 'keterangan', 'Saldo2Comp', 'Qnt2Opname', 'Selisih2', 'Qnt2DB', 'Qnt2CR', 'IsCek', 'IsCek2'
    ];

    protected $casts = [
        'QntOpname' => 'decimal:2',
        'QNTDB' => 'decimal:2',
        'QNTCR' => 'decimal:2',
        'HARGA' => 'decimal:2',
        'Qnt2Opname' => 'decimal:2',
        'Qnt2DB' => 'decimal:2',
        'Qnt2CR' => 'decimal:2',
        'IsCek' => 'boolean',
        'IsCek2' => 'boolean'
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
        return $this->belongsTo(DbKOREKSI::class, 'NOBUKTI', 'NOBUKTI');
    }

}