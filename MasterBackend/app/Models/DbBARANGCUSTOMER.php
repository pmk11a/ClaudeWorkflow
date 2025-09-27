<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBARANGCUSTOMER extends Model
{
    use HasFactory;

    protected $table = 'DBBARANGCUSTOMER';
    protected $primaryKey = ['KodecustSupp', 'KodeBrg'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodecustSupp', 'KodeBrg', 'Sat_1', 'Harga_1', 'Sat_2', 'Harga_2', 'Harga', 'Komisi'
    ];

    protected $casts = [
        'Harga_1' => 'decimal:2',
        'Harga_2' => 'decimal:2',
        'Harga' => 'decimal:2'
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
        return $this->hasMany(DbBARANGCUSTOMERDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}