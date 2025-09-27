<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbNERACANKA extends Model
{
    use HasFactory;

    protected $table = 'DBNERACANKA';
    protected $primaryKey = ['Perkiraan', 'Bulan', 'Tahun', 'Devisi'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Perkiraan', 'Bulan', 'Tahun', 'Devisi', 'DK', 'Valas', 'Kurs', 'AwalD', 'AwalK', 'AwalDRp', 'AwalKRp'
    ];

    protected $casts = [
        'Kurs' => 'decimal:2'
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
        return $this->hasMany(DbNERACANKADET::class, 'NOBUKTI', 'NOBUKTI');
    }

}