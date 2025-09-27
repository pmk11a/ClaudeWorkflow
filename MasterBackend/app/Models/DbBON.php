<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBON extends Model
{
    use HasFactory;

    protected $table = 'DBBON';
    protected $primaryKey = ['Devisi', 'NoBukti', 'Perkiraan', 'Urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Devisi', 'NoBukti', 'NOURUT', 'Tanggal', 'Penerima', 'Keterangan', 'Debet', 'Kredit', 'Perkiraan', 'TglInput', 'UserID', 'Urut', 'BuktiKas', 'UrutKas', 'MyID', 'KodeVls', 'Kurs', 'DebetD', 'KreditD'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'TglInput' => 'datetime',
        'MyID' => 'datetime',
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
        return $this->hasMany(DbBONDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}