<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbPO extends Model
{
    use HasFactory;

    protected $table = 'DBPO';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'TglJatuhTempo', 'KODESUPP', 'HANDLING', 'KODEEXP', 'KETERANGAN', 'FAKTURSUPP', 'KODEVLS', 'KURS', 'PPN', 'TIPEBAYAR', 'HARI', 'TipeDisc', 'DISC', 'DISCRP', 'ISCETAK', 'NilaiCetak', 'IsBatal', 'UserBatal', 'IsClose', 'IsExp', 'isAut', 'KodeGDG', 'cetakke', 'IsOtorisasi1', 'OtoUser1', 'TglOto1', 'IsOtorisasi2', 'OtoUser2', 'TglOto2', 'IsOtorisasi3', 'OtoUser3', 'TglOto3', 'IsOtorisasi4', 'OtoUser4', 'TglOto4', 'IsOtorisasi5', 'OtoUser5', 'TglOto5', 'NoJurnal', 'NoUrutJurnal', 'TglJurnal', 'MaxOL', 'TglBatal', 'flagtipe', 'TipePPN'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TglJatuhTempo' => 'datetime',
        'HANDLING' => 'decimal:2',
        'KURS' => 'decimal:2',
        'TipeDisc' => 'boolean',
        'DISCRP' => 'decimal:2',
        'ISCETAK' => 'boolean',
        'IsBatal' => 'boolean',
        'IsClose' => 'boolean',
        'IsExp' => 'boolean',
        'isAut' => 'boolean',
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
        'TglBatal' => 'datetime',
        'flagtipe' => 'boolean'
    ];


    // Model Events
    protected static function boot()
    {
        parent::boot();
        
        // Event ketika PO baru dibuat
        static::creating(function ($po) {
            // Auto-set tanggal jika kosong
            if (empty($po->TANGGAL)) {
                $po->TANGGAL = now();
            }
            
            // Auto-generate NOURUT berdasarkan tahun
            if (empty($po->NOURUT)) {
                $year = date('Y', strtotime($po->TANGGAL));
                $lastPO = static::whereYear('TANGGAL', $year)
                               ->orderBy('NOURUT', 'desc')
                               ->first();
                $po->NOURUT = $lastPO ? $lastPO->NOURUT + 1 : 1;
            }
        });
        
        // Event setelah PO dibuat
        static::created(function ($po) {
            \Log::info('New PO created', [
                'NOBUKTI' => $po->NOBUKTI,
                'KODESUPP' => $po->KODESUPP,
                'user' => auth()->user()->name ?? 'system'
            ]);
        });
        
        // Event sebelum PO diupdate
        static::updating(function ($po) {
            if ($po->isDirty('IsClose') && $po->IsClose) {
                \Log::info('PO being closed', ['NOBUKTI' => $po->NOBUKTI]);
            }
        });
    }

    // Relationships
    public function customer_supplier()
    {
        return $this->belongsTo(Dbcustsupp::class, 'KODESUPP', 'KODECUSTSUPP');
    }

    public function details()
    {
        return $this->hasMany(DbPODET::class, 'NOBUKTI', 'NOBUKTI');
    }

    // Custom Events
    public function close()
    {
        if ($this->IsClose) {
            return false;
        }
        
        // Fire custom event
        event('po.closing', $this);
        
        $this->update(['IsClose' => true, 'TglBatal' => now()]);
        
        // Fire custom event
        event('po.closed', $this);
        
        return true;
    }

    public function approve($level = 1, $user = null)
    {
        $user = $user ?? auth()->user()->name;
        
        // Fire custom event
        event('po.approving', [$this, $level, $user]);
        
        $approvalField = "IsOtorisasi{$level}";
        $userField = "OtoUser{$level}";
        $dateField = "TglOto{$level}";
        
        $this->update([
            $approvalField => true,
            $userField => $user,
            $dateField => now()
        ]);
        
        // Fire custom event
        event('po.approved', [$this, $level, $user]);
        
        return true;
    }

}