<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempdbTransaksi extends Model
{
    use HasFactory;

    protected $table = 'TempdbTransaksi';
    protected $primaryKey = ['NoBukti', 'Urut', 'FlagSimbol'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Tanggal', 'Devisi', 'Note', 'Lampiran', 'Perkiraan', 'Lawan', 'Keterangan', 'Keterangan2', 'Debet', 'Kredit', 'Valas', 'Kurs', 'DebetRp', 'KreditRp', 'TipeTrans', 'TPHC', 'CustSuppP', 'CustSuppL', 'Urut', 'KodeP', 'KodeL', 'NoAktivaP', 'NoAktivaL', 'StatusAktivaP', 'StatusAktivaL', 'Nobon', 'KodeBag', 'StatusGiro', 'MyID', 'FlagSimbol', 'KODECOST', 'KODESUBCOST'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'Lampiran' => 'decimal:2',
        'Debet' => 'decimal:2',
        'Kredit' => 'decimal:2',
        'Kurs' => 'decimal:2',
        'DebetRp' => 'decimal:2',
        'KreditRp' => 'decimal:2',
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
