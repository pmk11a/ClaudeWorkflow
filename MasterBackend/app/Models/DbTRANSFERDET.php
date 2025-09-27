<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTRANSFERDET extends Model
{
    use HasFactory;

    protected $table = 'DBTRANSFERDET';
    protected $primaryKey = ['NOBUKTI', 'URUT'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'GDGASAL', 'GDGTUJUAN', 'SAT_1', 'SAT_2', 'NOSAT', 'ISI', 'QNT', 'QNT2', 'HARGA', 'HPP', 'MyID'
    ];

    protected $casts = [
        'ISI' => 'decimal:2',
        'QNT' => 'decimal:2',
        'QNT2' => 'decimal:2',
        'HARGA' => 'decimal:2',
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


    // Relationships
    public function header()
    {
        return $this->belongsTo(DbTRANSFER::class, 'NOBUKTI', 'NOBUKTI');
    }

    public function item()
    {
        return $this->belongsTo(DbBARANG::class, 'KODEBRG', 'KODEBRG');
    }

}
