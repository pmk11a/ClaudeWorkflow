<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbJUAL extends Model
{
    use HasFactory;

    protected $table = 'DBJUAL';
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NOBUKTI', 'NOURUT', 'TANGGAL', 'TGLJATUHTEMPO', 'KODECUST', 'KODESLS', 'KODEGDG', 'HANDLING', 'KETERANGAN', 'KODEVLS', 'KURS', 'PPN', 'TIPEBAYAR', 'HARI', 'CATATAN', 'TIPEDISC', 'DISC', 'DISCRP', 'NILAIPOT', 'NILAIDPP', 'NILAIPPN', 'NILAINET', 'ISCETAK', 'ISBATAL', 'USERBATAL', 'NOPAJAK', 'KodeExp', 'INSGdg', 'INSBrg', 'TGLFPJ', 'NobuktiUM', 'NewNo', 'Term', 'FlagTipe'
    ];

    protected $casts = [
        'TANGGAL' => 'datetime',
        'TGLJATUHTEMPO' => 'datetime',
        'HANDLING' => 'decimal:2',
        'KURS' => 'decimal:2',
        'TIPEDISC' => 'boolean',
        'DISCRP' => 'decimal:2',
        'NILAIPOT' => 'decimal:2',
        'NILAIDPP' => 'decimal:2',
        'NILAIPPN' => 'decimal:2',
        'NILAINET' => 'decimal:2',
        'ISCETAK' => 'boolean',
        'ISBATAL' => 'boolean',
        'TGLFPJ' => 'datetime'
    ];

    // Model Events
    protected static function boot()
    {
        parent::boot();
        
        // Event ketika Sales baru dibuat
        static::creating(function ($jual) {
            // Auto-set tanggal jika kosong
            if (empty($jual->TANGGAL)) {
                $jual->TANGGAL = now();
            }
            
            // Auto-generate NOURUT berdasarkan tahun
            if (empty($jual->NOURUT)) {
                $year = date('Y', strtotime($jual->TANGGAL));
                $lastJual = static::whereYear('TANGGAL', $year)
                                 ->orderBy('NOURUT', 'desc')
                                 ->first();
                $jual->NOURUT = $lastJual ? $lastJual->NOURUT + 1 : 1;
            }
            
            // Set due date jika belum ada
            if (empty($jual->TGLJATUHTEMPO) && !empty($jual->HARI)) {
                $jual->TGLJATUHTEMPO = now()->addDays($jual->HARI);
            }
        });
        
        // Event setelah Sales dibuat
        static::created(function ($jual) {
            \Log::info('New Sales created', [
                'NOBUKTI' => $jual->NOBUKTI,
                'KODECUST' => $jual->KODECUST,
                'NILAINET' => $jual->NILAINET,
                'user' => auth()->user()->name ?? 'system'
            ]);
        });
        
        // Event sebelum Sales diupdate
        static::updating(function ($jual) {
            if ($jual->isDirty('ISBATAL') && $jual->ISBATAL) {
                \Log::warning('Sales being cancelled', [
                    'NOBUKTI' => $jual->NOBUKTI,
                    'reason' => 'Manual cancellation'
                ]);
            }
        });
        
        // Event setelah Sales diupdate
        static::updated(function ($jual) {
            if ($jual->wasChanged('NILAINET')) {
                \Log::info('Sales amount changed', [
                    'NOBUKTI' => $jual->NOBUKTI,
                    'old_amount' => $jual->getOriginal('NILAINET'),
                    'new_amount' => $jual->NILAINET
                ]);
            }
        });
    }

    // Relationships
    public function customer_supplier()
    {
        return $this->belongsTo(Dbcustsupp::class, 'KODECUST', 'KODECUSTSUPP');
    }

    public function details()
    {
        return $this->hasMany(DbJUALDET::class, 'NOBUKTI', 'NOBUKTI');
    }

    // Custom Methods dengan Events
    public function cancel($reason = 'Manual cancellation')
    {
        if ($this->ISBATAL) {
            return false;
        }
        
        // Fire custom event
        event('sales.cancelling', [$this, $reason]);
        
        $this->update([
            'ISBATAL' => true,
            'USERBATAL' => auth()->user()->name ?? 'system'
        ]);
        
        // Fire custom event
        event('sales.cancelled', [$this, $reason]);
        
        return true;
    }

    public function calculateTotal()
    {
        $total = $this->details()->sum(\DB::raw('QNT * HARGA'));
        $this->update(['NILAINET' => $total]);
        
        event('sales.total.calculated', $this);
        
        return $total;
    }

}