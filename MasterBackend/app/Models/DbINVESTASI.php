<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbINVESTASI extends Model
{
    use HasFactory;

    protected $table = 'DBINVESTASI';
    protected $primaryKey = ['Devisi', 'Perkiraan'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Devisi', 'Perkiraan', 'Keterangan', 'Quantity', 'Persen', 'TglPerolehan', 'TglJatuhTempo', 'Tipe', 'Akumulasi', 'NoMuka', 'Biaya', 'NoBelakang', 'NoInvestasiHd', 'Kelompok', 'GroupInvestasi', 'TipeInvestasi', 'NilaiNominal'
    ];

    protected $casts = [
        'TglPerolehan' => 'datetime',
        'TglJatuhTempo' => 'datetime',
        'NilaiNominal' => 'decimal:2'
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
        return $this->hasMany(DbINVESTASIDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}