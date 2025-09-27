<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbRPenyerahanBhnDET extends Model
{
    use HasFactory;

    protected $table = 'DBRPenyerahanBhnDET';
    protected $primaryKey = ['Nobukti', 'urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Nobukti', 'urut', 'kodebrg', 'Sat', 'Nosat', 'Isi', 'Qnt', 'Qnt2', 'HPP', 'NoPenyerahanBHN', 'UrutPenyerahanBHN'
    ];

    protected $casts = [
        'Isi' => 'decimal:2',
        'Qnt' => 'decimal:2',
        'Qnt2' => 'decimal:2',
        'HPP' => 'decimal:2',
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
