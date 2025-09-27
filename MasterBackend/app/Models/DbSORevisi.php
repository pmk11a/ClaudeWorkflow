<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSORevisi extends Model
{
    use HasFactory;

    protected $table = 'DBSORevisi';
    protected $primaryKey = ['NOBUKTI', 'RevisiKe'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'RevisiKe', 'NOURUT', 'TANGGAL', 'TGLJATUHTEMPO', 'KODECUST', 'NOSPB', 'NoAlamatKirim', 'AlamatKirim', 'HANDLING', 'KODESLS', 'KETERANGAN', 'KODEVLS', 'KURS', 'PPN', 'TIPEBAYAR', 'HARI', 'CATATAN', 'TIPEDISC', 'DISC', 'DISCRP', 'NILAIPOT', 'NILAIDPP', 'NILAIPPN', 'NILAINET', 'ISCETAK', 'ISBATAL', 'USERBATAL', 'KODEGDG', 'KodeExp', 'INSGdg', 'INSBrg', 'Jam', 'NewNo', 'FLAGTIPE', 'NOPI', 'TIPESC', 'TERM1P', 'TERM1VLS', 'TERM1KURS', 'TERM1KET', 'TERM2P', 'TERM2VLS', 'TERM2KURS', 'TERM2KET', 'TERM3P', 'TERM3VLS', 'TERM3KURS', 'TERM3KET', 'TERM4P', 'TERM4VLS', 'TERM4KURS', 'TERM4KET', 'TERM5P', 'TERM5VLS', 'TERM5KURS', 'TERM5KET', 'KetTipeEkspor', 'IsLengkap', 'userid', 'TglInput', 'NoPesanan', 'TglKirim', 'MasaBerlaku', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'cetakke', 'MAXOL', 'tglRevisi'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TGLJATUHTEMPO' => 'datetime',
        'HANDLING' => 'decimal:2',
        'KURS' => 'decimal:2',
        'DISC' => 'decimal:2',
        'DISCRP' => 'decimal:2',
        'NILAIPOT' => 'decimal:2',
        'NILAIDPP' => 'decimal:2',
        'NILAIPPN' => 'decimal:2',
        'NILAINET' => 'decimal:2',
        'ISBATAL' => 'boolean',
        'Jam' => 'datetime',
        'TERM1P' => 'decimal:2',
        'TERM1KURS' => 'decimal:2',
        'TERM2P' => 'decimal:2',
        'TERM2KURS' => 'decimal:2',
        'TERM3P' => 'decimal:2',
        'TERM3KURS' => 'decimal:2',
        'TERM4P' => 'decimal:2',
        'TERM4KURS' => 'decimal:2',
        'TERM5P' => 'decimal:2',
        'TERM5KURS' => 'decimal:2',
        'IsLengkap' => 'boolean',
        'TglInput' => 'datetime',
        'TglKirim' => 'datetime',
        'MasaBerlaku' => 'datetime',
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
        'TglJurnal' => 'datetime',
        'tglRevisi' => 'datetime',
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

}
