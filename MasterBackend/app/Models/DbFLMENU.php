<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbFLMENU extends Model
{
    use HasFactory;

    protected $table = 'DBFLMENU';
    protected $primaryKey = ['USERID', 'L1'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'USERID', 'L1', 'HASACCESS', 'ISTAMBAH', 'ISKOREKSI', 'ISHAPUS', 'ISCETAK', 'ISEXPORT', 'IsOtorisasi1', 'IsOtorisasi2', 'IsOtorisasi3', 'IsOtorisasi4', 'IsOtorisasi5', 'TIPE', 'IsBatal', 'pembatalan'
    ];

    protected $casts = [
        'HASACCESS' => 'boolean',
        'ISTAMBAH' => 'boolean',
        'ISKOREKSI' => 'boolean',
        'ISHAPUS' => 'boolean',
        'ISCETAK' => 'boolean',
        'ISEXPORT' => 'boolean',
        'IsOtorisasi1' => 'boolean',
        'IsOtorisasi2' => 'boolean',
        'IsOtorisasi3' => 'boolean',
        'IsOtorisasi4' => 'boolean',
        'IsOtorisasi5' => 'boolean',
        'IsBatal' => 'boolean',
        'pembatalan' => 'boolean'
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
    public function user()
    {
        return $this->belongsTo(DbFLPASS::class, 'USERID', 'USERID');
    }

    public function menu()
    {
        return $this->belongsTo(DbMENU::class, 'L1', 'KODEMENU');
    }

}