<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbINVESTASIDET extends Model
{
    use HasFactory;

    protected $table = 'DBINVESTASIDET';
    protected $primaryKey = ['Perkiraan', 'Bulan', 'Tahun', 'Devisi'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Bulan', 'Tahun', 'Devisi', 'Valas', 'Kurs', 'Tipe', 'NilaiNominal', 'Awal', 'AwalPasar', 'AwalD', 'AwalPasarD', 'BungaRp', 'PersenJual', 'MD', 'DMD', 'MK', 'DMK', 'SD', 'DSD', 'SK', 'DSK', 'Akhir', 'AkhirD', 'AkhirPasarD', 'MyID', 'NilaiPasar', 'UnitRKSD', 'NAB', 'SPI1', 'Akhirpasar', 'SPI'
    ];

    protected $casts = [
        'Kurs' => 'decimal:2',
        'NilaiNominal' => 'decimal:2',
        'MyID' => 'datetime',
        'NilaiPasar' => 'decimal:2'
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
    public function header()
    {
        return $this->belongsTo(DbINVESTASI::class, 'NOBUKTI', 'NOBUKTI');
    }

}