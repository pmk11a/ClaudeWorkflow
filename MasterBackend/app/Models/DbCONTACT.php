<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbCONTACT extends Model
{
    use HasFactory;

    protected $table = 'DBCONTACT';
    protected $primaryKey = ['CONTACTID', 'KODECUSTSUPP'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'CONTACTID', 'KODECUSTSUPP', 'TITLE', 'FIRSTNAME', 'MIDDLENAME', 'LASTNAME', 'JOBTITLE', 'COMPANY', 'PHONETYPE1', 'PHONE1', 'PHONETYPE2', 'PHONE2', 'PHONETYPE3', 'PHONE3', 'PHONETYPE4', 'PHONE4', 'ALAMAT', 'EMAIL', 'DEPARTEMEN', 'BIRTHDAY', 'ANNIVERSARY', 'PHOTO', 'MyID'
    ];

    protected $casts = [
        'BIRTHDAY' => 'datetime',
        'ANNIVERSARY' => 'datetime',
        'MyID' => 'datetime'
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
        return $this->hasMany(DbCONTACTDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}