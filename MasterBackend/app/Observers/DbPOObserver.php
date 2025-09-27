<?php

namespace App\Observers;

use App\Models\DbPO;
use App\Models\DbSTOCKBRG;
use Illuminate\Support\Facades\Log;

class DbPOObserver
{
    public function creating(DbPO $po)
    {
        // Auto generate NOURUT if not provided
        if (empty($po->NOURUT)) {
            $lastPO = DbPO::where('TANGGAL', '>=', now()->startOfYear())
                          ->orderBy('NOURUT', 'desc')
                          ->first();
            $po->NOURUT = $lastPO ? $lastPO->NOURUT + 1 : 1;
        }

        // Set default values
        $po->ISCETAK = $po->ISCETAK ?? false;
        $po->IsBatal = $po->IsBatal ?? false;
        $po->IsClose = $po->IsClose ?? false;
        $po->isAut = $po->isAut ?? false;
        
        Log::info('PO creating', ['NOBUKTI' => $po->NOBUKTI, 'KODESUPP' => $po->KODESUPP]);
    }

    public function created(DbPO $po)
    {
        Log::info('PO created successfully', ['NOBUKTI' => $po->NOBUKTI]);
    }

    public function updating(DbPO $po)
    {
        // Prevent modification if already closed
        if ($po->getOriginal('IsClose') && $po->isDirty()) {
            throw new \Exception('Cannot modify closed PO: ' . $po->NOBUKTI);
        }

        // Log critical changes
        if ($po->isDirty('KODESUPP')) {
            Log::warning('PO supplier changed', [
                'NOBUKTI' => $po->NOBUKTI,
                'old_supplier' => $po->getOriginal('KODESUPP'),
                'new_supplier' => $po->KODESUPP
            ]);
        }
    }

    public function updated(DbPO $po)
    {
        // Auto-close PO if all items are received
        if ($po->IsClose && !$po->getOriginal('IsClose')) {
            Log::info('PO closed', ['NOBUKTI' => $po->NOBUKTI]);
        }
    }

    public function deleting(DbPO $po)
    {
        // Prevent deletion if PO has been processed
        if ($po->IsClose || $po->ISCETAK) {
            throw new \Exception('Cannot delete processed PO: ' . $po->NOBUKTI);
        }

        // Check if PO has related receipts
        if ($po->details()->exists()) {
            Log::warning('Deleting PO with details', ['NOBUKTI' => $po->NOBUKTI]);
        }
    }

    public function deleted(DbPO $po)
    {
        Log::info('PO deleted', ['NOBUKTI' => $po->NOBUKTI]);
    }
}