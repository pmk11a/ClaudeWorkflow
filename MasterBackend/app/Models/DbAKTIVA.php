<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbAKTIVA extends Model
{
    use HasFactory;

    protected $table = 'DBAKTIVA';
    protected $primaryKey = ['Devisi', 'Perkiraan'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Devisi', 'Perkiraan', 'Keterangan', 'Quantity', 'Persen', 'Tanggal', 'Tipe', 'Kodebag', 'Akumulasi', 'NoMuka', 'NoBelakang', 'Biaya', 'PersenBiaya1', 'Biaya2', 'PersenBiaya2', 'biaya3', 'persenbiaya3', 'biaya4', 'persenbiaya4', 'TipeAktiva', 'NoBelakang2', 'NoAktivaHd', 'Kelompok', 'GroupAktiva', 'NoBuktiSem'
    ];

    protected $casts = [
        'Tanggal' => 'datetime'
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
        return $this->hasMany(DbAKTIVADET::class, 'NOBUKTI', 'NOBUKTI');
    }

}