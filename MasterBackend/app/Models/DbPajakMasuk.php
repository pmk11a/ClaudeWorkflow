<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPajakMasuk extends Model
{
    use HasFactory;

    protected $table = 'DBPajakMasuk';
    protected $primaryKey = ['NoBukti', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoBukti', 'Urut', 'NOFPJ', 'TGLFPJ', 'NPPn', 'TglLaporFPJ', 'TipePPh', 'NoPPh', 'TglPPh', 'nPPh', 'TglLaporPPh', 'NPWP', 'NamaPKP', 'AlamatPKP1', 'AlamatPKP2', 'KotaPKP', 'MyID', 'UrutTrans'
    ];

    protected $casts = [
        'TGLFPJ' => 'datetime',
        'TglLaporFPJ' => 'datetime',
        'TglPPh' => 'datetime',
        'TglLaporPPh' => 'datetime',
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
        return $this->hasMany(DbPajakMasukDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}