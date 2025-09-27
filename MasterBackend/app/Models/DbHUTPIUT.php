<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbHUTPIUT extends Model
{
    use HasFactory;

    protected $table = 'DBHUTPIUT';
    protected $primaryKey = ['NoFaktur', 'NoRetur', 'TipeTrans', 'KodeCustSupp', 'NoBukti', 'NoMsk', 'Urut', 'Tipe', 'Perkiraan'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoFaktur', 'NoRetur', 'TipeTrans', 'KodeCustSupp', 'NoBukti', 'NoMsk', 'Urut', 'Tanggal', 'JatuhTempo', 'Debet', 'Kredit', 'Saldo', 'Valas', 'Kurs', 'DebetD', 'KreditD', 'SaldoD', 'KodeSales', 'Tipe', 'Perkiraan', 'Catatan', 'MyID', 'NOINVOICE', 'TGLINVOICE', 'NOPAJAK', 'TGLFPJ', 'KodeVls_', 'Kurs_', 'KursBayar', 'FlagSimbol', 'Tipebayar', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'IsClose', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL', 'Nourut', 'KBLB'
    ];

    protected $casts = [
        'Tanggal' => 'datetime',
        'JatuhTempo' => 'datetime',
        'Kurs' => 'decimal:2',
        'MyID' => 'datetime',
        'TGLINVOICE' => 'datetime',
        'TGLFPJ' => 'datetime',
        'Kurs_' => 'decimal:2',
        'KursBayar' => 'decimal:2',
        'IsOtorisasi1' => 'boolean',
        'TglOto1' => 'datetime',
        'IsOtorisasi2' => 'boolean',
        'TglOto2' => 'datetime',
        'IsOtorisasi3' => 'boolean',
        'TglOto3' => 'datetime',
        'IsOtorisasi4' => 'boolean',
        'TglOto4' => 'datetime',
        'IsOtorisasi5' => 'boolean',
        'TglOto5' => 'datetime',
        'IsClose' => 'boolean',
        'TglJurnal' => 'datetime'
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
        return $this->hasMany(DbHUTPIUTDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}