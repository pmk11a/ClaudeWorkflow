<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPORevDET extends Model
{
    use HasFactory;

    protected $table = 'DBPORevDET';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'URUT', 'KODEBRG', 'NAMABRG', 'PPN', 'DISC', 'QNT', 'QntBatal', 'TglBatal', 'NOSAT', 'SATUAN', 'ISI', 'HARGA', 'DISCP', 'DISCTOT', 'BYANGKUT', 'HRGNETTO', 'NDISKON', 'SUBTOTAL', 'NDPP', 'NPPN', 'NNET', 'NoPPL', 'IsClose', 'Catatan', 'revisike', 'DiscP2', 'DiscP3', 'DiscP4', 'DiscP5', 'IsJasa'
    ];

    protected $casts = [
        'QNT' => 'decimal:2',
        'QntBatal' => 'decimal:2',
        'TglBatal' => 'datetime',
        'HARGA' => 'decimal:2',
        'DISCP' => 'decimal:2',
        'DISCTOT' => 'decimal:2',
        'SUBTOTAL' => 'decimal:2',
        'IsClose' => 'boolean',
        'DiscP2' => 'decimal:2',
        'DiscP3' => 'decimal:2',
        'DiscP4' => 'decimal:2',
        'DiscP5' => 'decimal:2',
        'IsJasa' => 'boolean'
    ];


    // Relationships
    public function item()
    {
        return $this->belongsTo(Dbbarang::class, 'KODEBRG', 'KODEBRG');
    }

    public function header()
    {
        return $this->belongsTo(DbPORev::class, 'NOBUKTI', 'NOBUKTI');
    }

}