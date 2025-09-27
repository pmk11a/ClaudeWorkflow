<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbKreditNoteDET extends Model
{
    use HasFactory;

    protected $table = 'DBKreditNoteDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'NoInv', 'Keterangan', 'Nilai', 'KodeVLS', 'Kurs', 'NilaiRp', 'perkHP'
    ];

    protected $casts = [
        'Nilai' => 'decimal:2',
        'Kurs' => 'decimal:2',
        'NilaiRp' => 'decimal:2'
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
    public function header()
    {
        return $this->belongsTo(DbKreditNote::class, 'NOBUKTI', 'NOBUKTI');
    }

}