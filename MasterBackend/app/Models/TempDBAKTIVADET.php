<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempDBAKTIVADET extends Model
{
    use HasFactory;

    protected $table = 'TempDBAKTIVADET';
    protected $primaryKey = ['Perkiraan', 'Bulan', 'Tahun', 'Devisi'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Bulan', 'Tahun', 'Devisi', 'Valas', 'Kurs', 'Awal', 'AwalSusut', 'AwalD', 'AwalSusutD', 'MD', 'DMD', 'MK', 'DMK', 'SD', 'DSD', 'SK', 'DSK', 'Akhir', 'AkhirD', 'AkhirSusutD', 'MyID', 'AkhirSusut'
    ];

    protected $casts = [
        'Kurs' => 'decimal:2',
        'Awal' => 'decimal:2',
        'AwalSusut' => 'decimal:2',
        'AwalD' => 'decimal:2',
        'AwalSusutD' => 'decimal:2',
        'MD' => 'decimal:2',
        'DMD' => 'decimal:2',
        'MK' => 'decimal:2',
        'DMK' => 'decimal:2',
        'SD' => 'decimal:2',
        'DSD' => 'decimal:2',
        'SK' => 'decimal:2',
        'DSK' => 'decimal:2',
        'Akhir' => 'decimal:2',
        'AkhirD' => 'decimal:2',
        'AkhirSusutD' => 'decimal:2',
        'AkhirSusut' => 'decimal:2',
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
