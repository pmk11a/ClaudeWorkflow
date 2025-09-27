<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbLRHPP extends Model
{
    use HasFactory;

    protected $table = 'DBLRHPP';
    protected $primaryKey = ['Bulan', 'Tahun', 'Devisi', 'Perkiraan', 'Nomor'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Bulan', 'Tahun', 'Devisi', 'Perkiraan', 'Nomor', 'Keterangan', 'Grup', 'Tipe', 'Tanda', 'Persen', 'Jumlah', 'Tampil', 'TotalA', 'TotalB', 'TotalC', 'IsLRHPP', 'TotalD'
    ];

    protected $casts = [
        'TotalA' => 'decimal:2',
        'TotalB' => 'decimal:2',
        'TotalC' => 'decimal:2',
        'IsLRHPP' => 'boolean',
        'TotalD' => 'decimal:2'
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
        return $this->hasMany(DbLRHPPDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}