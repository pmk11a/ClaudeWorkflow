<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSPKDET extends Model
{
    use HasFactory;

    protected $table = 'DBSPKDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'QNT', 'NOSAT', 'SATUAN', 'ISI', 'QntBOMX', 'KodeBOMDet', 'StrLevelBOM', 'IntLevelBOM', 'KodePrs'
    ];

    protected $casts = [
        'QNT' => 'decimal:2',
        'ISI' => 'decimal:2',
        'QntBOMX' => 'decimal:2',
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
        return $this->belongsTo(DbSPK::class, 'NOBUKTI', 'NOBUKTI');
    }

    public function material()
    {
        return $this->belongsTo(DbBARANG::class, 'KODEBAHAN', 'KODEBRG');
    }

}
