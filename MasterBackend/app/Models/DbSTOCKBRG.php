<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSTOCKBRG extends Model
{
    use HasFactory;

    protected $table = 'DBSTOCKBRG';
    protected $primaryKey = ['BULAN', 'TAHUN', 'KODEBRG', 'KODEGDG'];
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'BULAN', 'TAHUN', 'KODEBRG', 'KODEGDG', 'QNTAWAL', 'QNT2AWAL', 'HRGAWAL', 'QNTPBL', 'QNT2PBL', 'HRGPBL', 'QNTRPB', 'QNT2RPB', 'HRGRPB', 'QNTPNJ', 'QNT2PNJ', 'HRGPNJ', 'QNTRPJ', 'QNT2RPJ', 'HRGRPJ', 'QNTPRJ', 'HRGPRJ', 'QNTADI', 'QNT2ADI', 'HRGADI', 'QNTADO', 'QNT2ADO', 'HRGADO', 'QNTUKI', 'QNT2UKI', 'HRGUKI', 'QNTUKO', 'QNT2UKO', 'HRGUKO', 'QNTTRI', 'HRGTRI', 'QNT2TRI', 'QNTTRO', 'QNT2TRO', 'HRGTRO', 'QNTPMK', 'QNT2PMK', 'HRGPMK', 'QNTRPK', 'QNT2RPK', 'HRGRPK', 'QntHPrd', 'Qnt2HPrd', 'HRGHPrd', 'HRGRATA', 'QNTIN', 'QNT2IN', 'RPIN', 'QNTOUT', 'QNT2OUT', 'RPOUT', 'SALDOQNT', 'SALDO2QNT', 'SALDORP', 'SaldoAV', 'Saldo2AV'
    ];

    protected $casts = [
        'QNTAWAL' => 'decimal:2',
        'QNT2AWAL' => 'decimal:2',
        'HRGAWAL' => 'decimal:2',
        'QNTPBL' => 'decimal:2',
        'QNT2PBL' => 'decimal:2',
        'HRGPBL' => 'decimal:2',
        'QNTRPB' => 'decimal:2',
        'QNT2RPB' => 'decimal:2',
        'HRGRPB' => 'decimal:2',
        'QNTPNJ' => 'decimal:2',
        'QNT2PNJ' => 'decimal:2',
        'HRGPNJ' => 'decimal:2',
        'QNTRPJ' => 'decimal:2',
        'QNT2RPJ' => 'decimal:2',
        'HRGRPJ' => 'decimal:2',
        'QNTPRJ' => 'decimal:2',
        'HRGPRJ' => 'decimal:2',
        'QNTADI' => 'decimal:2',
        'QNT2ADI' => 'decimal:2',
        'HRGADI' => 'decimal:2',
        'QNTADO' => 'decimal:2',
        'QNT2ADO' => 'decimal:2',
        'HRGADO' => 'decimal:2',
        'QNTUKI' => 'decimal:2',
        'QNT2UKI' => 'decimal:2',
        'HRGUKI' => 'decimal:2',
        'QNTUKO' => 'decimal:2',
        'QNT2UKO' => 'decimal:2',
        'HRGUKO' => 'decimal:2',
        'QNTTRI' => 'decimal:2',
        'HRGTRI' => 'decimal:2',
        'QNT2TRI' => 'decimal:2',
        'QNTTRO' => 'decimal:2',
        'QNT2TRO' => 'decimal:2',
        'HRGTRO' => 'decimal:2',
        'QNTPMK' => 'decimal:2',
        'QNT2PMK' => 'decimal:2',
        'HRGPMK' => 'decimal:2',
        'QNTRPK' => 'decimal:2',
        'QNT2RPK' => 'decimal:2',
        'HRGRPK' => 'decimal:2',
        'QntHPrd' => 'decimal:2',
        'Qnt2HPrd' => 'decimal:2',
        'HRGHPrd' => 'decimal:2',
        'HRGRATA' => 'decimal:2',
        'QNTIN' => 'decimal:2',
        'QNT2IN' => 'decimal:2',
        'RPIN' => 'decimal:2',
        'QNTOUT' => 'decimal:2',
        'QNT2OUT' => 'decimal:2',
        'RPOUT' => 'decimal:2',
        'SALDOQNT' => 'decimal:2',
        'SALDO2QNT' => 'decimal:2',
        'SALDORP' => 'decimal:2',
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
