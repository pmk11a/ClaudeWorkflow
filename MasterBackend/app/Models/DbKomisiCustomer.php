<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKomisiCustomer extends Model
{
    use HasFactory;

    protected $table = 'DBKomisiCustomer';
    protected $primaryKey = ['KodeCustSupp', 'KodeBrg', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeCustSupp', 'KodeBrg', 'Urut', 'Nama', 'Kurir', 'Kurir_2', 'islunas'
    ];

    protected $casts = [
        'islunas' => 'boolean'
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
        return $this->hasMany(DbKomisiCustomerDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}