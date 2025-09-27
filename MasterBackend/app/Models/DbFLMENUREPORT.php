<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbFLMENUREPORT extends Model
{
    use HasFactory;

    protected $table = 'DBFLMENUREPORT';
    protected $primaryKey = ['UserID', 'L1'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'UserID', 'L1', 'Access', 'IsDesign', 'Isexport'
    ];

    protected $casts = [
        'Access' => 'boolean',
        'IsDesign' => 'boolean',
        'Isexport' => 'boolean'
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
        return $this->hasMany(DbFLMENUREPORTDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}