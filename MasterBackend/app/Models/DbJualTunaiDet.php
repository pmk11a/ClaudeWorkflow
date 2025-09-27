<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJualTunaiDet extends Model
{
    use HasFactory;

    protected $table = 'dbJualTunaiDet';
    protected $primaryKey = ['NOBUKTI', 'URUT', 'KodeBrg', 'QNT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KodeBrg', 'HARGA', 'DISCP', 'QNT', 'NOSAT', 'SATUAN', 'ISI', 'Ctk', 'Diskon', 'hrgnetto', 'subtotal', 'TglBatal', 'isGratis', 'Keterangan', 'IsSelesai', 'IsKirim', 'TakeIn', 'TakeOut', 'UserIdBatal', 'KetBatal'
    ];

    protected $casts = [
        'HARGA' => 'decimal:2',
        'DISCP' => 'decimal:2',
        'QNT' => 'decimal:2',
        'Ctk' => 'boolean',
        'subtotal' => 'decimal:2',
        'TglBatal' => 'datetime',
        'isGratis' => 'boolean',
        'IsSelesai' => 'boolean',
        'IsKirim' => 'boolean',
        'TakeIn' => 'boolean',
        'TakeOut' => 'boolean'
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
        return $this->hasMany(DbJualTunaiDetDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}