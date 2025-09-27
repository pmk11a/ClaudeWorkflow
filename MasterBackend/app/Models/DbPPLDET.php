<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPPLDET extends Model
{
    use HasFactory;

    protected $table = 'DBPPLDET';
    protected $primaryKey = ['Nobukti', 'urut'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Nobukti', 'urut', 'kodebrg', 'NamaBrg', 'Sat', 'Nosat', 'Isi', 'Qnt', 'QntPO', 'Keterangan', 'IsClose', 'NoSPK', 'UrutSPK', 'NosatSPK', 'Isbatal', 'Tglbatal', 'UserBatal', 'Qntbatal', 'TglKirim', 'IsJasa', 'NOSO', 'URUTSO'
    ];

    protected $casts = [
        'Qnt' => 'decimal:2',
        'QntPO' => 'decimal:2',
        'IsClose' => 'boolean',
        'Isbatal' => 'boolean',
        'Tglbatal' => 'datetime',
        'Qntbatal' => 'decimal:2',
        'TglKirim' => 'datetime',
        'IsJasa' => 'boolean'
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
        return $this->belongsTo(DbPPL::class, 'NOBUKTI', 'NOBUKTI');
    }

}