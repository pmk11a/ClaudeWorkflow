<?php

namespace App\Observers;

use App\Models\DbPODET;
use App\Models\DbPO;
use App\Models\DbBARANG;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class DbPODETObserver
{
    public function creating(DbPODET $poDet)
    {
        // Replicate trigger: TRG_Add_DBPODet logic
        Log::info('PODET creating', [
            'NOBUKTI' => $poDet->NOBUKTI,
            'KODEBRG' => $poDet->KODEBRG,
            'QNT' => $poDet->QNT
        ]);
        
        // Set default values
        $poDet->QntBatal = $poDet->QntBatal ?? 0;
        $poDet->IsClose = $poDet->IsClose ?? false;
        $poDet->Isbatal = $poDet->Isbatal ?? false;
        $poDet->Isjasa = $poDet->Isjasa ?? false;
        
        // Auto-generate URUT if not provided
        if (empty($poDet->URUT)) {
            $maxUrut = DbPODET::where('NOBUKTI', $poDet->NOBUKTI)
                              ->max('URUT');
            $poDet->URUT = ($maxUrut ?? 0) + 1;
        }
        
        // Get item name from master
        if (empty($poDet->NamaBrg) && !empty($poDet->KODEBRG)) {
            $barang = DbBARANG::where('KODEBRG', $poDet->KODEBRG)->first();
            if ($barang) {
                $poDet->NamaBrg = $barang->NAMABRG;
            }
        }
    }

    public function created(DbPODET $poDet)
    {
        try {
            DB::transaction(function () use ($poDet) {
                // Update total pada header DBPO
                $this->updatePOTotal($poDet->NOBUKTI);
                
                // Mark PO as having details
                DbPO::where('NOBUKTI', $poDet->NOBUKTI)
                    ->update(['isAut' => true]);
            });
            
            Log::info('PODET created - PO total updated', [
                'NOBUKTI' => $poDet->NOBUKTI,
                'KODEBRG' => $poDet->KODEBRG
            ]);
            
        } catch (\Exception $e) {
            Log::error('PODET created - update failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $poDet->NOBUKTI
            ]);
        }
    }

    public function updating(DbPODET $poDet)
    {
        // Replicate trigger: Trg_UPD_DbPOdet logic
        
        // Prevent update if PO is closed
        $po = DbPO::where('NOBUKTI', $poDet->NOBUKTI)->first();
        if ($po && $po->IsClose) {
            throw new \Exception('Cannot update PODET: PO is already closed');
        }
        
        // Prevent update if item is already closed
        if ($poDet->getOriginal('IsClose') && $poDet->IsClose) {
            throw new \Exception('Cannot update PODET: Item is already closed');
        }
        
        $oldQty = $poDet->getOriginal('QNT');
        $newQty = $poDet->QNT;
        $oldPrice = $poDet->getOriginal('HARGA');
        $newPrice = $poDet->HARGA;
        
        if ($oldQty != $newQty || $oldPrice != $newPrice) {
            Log::info('PODET data changing', [
                'NOBUKTI' => $poDet->NOBUKTI,
                'KODEBRG' => $poDet->KODEBRG,
                'old_qty' => $oldQty,
                'new_qty' => $newQty,
                'old_price' => $oldPrice,
                'new_price' => $newPrice
            ]);
        }
    }

    public function updated(DbPODET $poDet)
    {
        // Update total jika quantity atau harga berubah
        $oldQty = $poDet->getOriginal('QNT');
        $newQty = $poDet->QNT;
        $oldPrice = $poDet->getOriginal('HARGA');
        $newPrice = $poDet->HARGA;
        
        if ($oldQty != $newQty || $oldPrice != $newPrice) {
            try {
                DB::transaction(function () use ($poDet) {
                    // Recalculate subtotal
                    $poDet->SUBTOTAL = $poDet->QNT * $poDet->HARGA;
                    $poDet->saveQuietly(); // Save without triggering events again
                    
                    // Update total pada header
                    $this->updatePOTotal($poDet->NOBUKTI);
                });
                
            } catch (\Exception $e) {
                Log::error('PODET updated - calculation failed', [
                    'error' => $e->getMessage(),
                    'NOBUKTI' => $poDet->NOBUKTI
                ]);
            }
        }
    }

    public function deleting(DbPODET $poDet)
    {
        // Replicate trigger: Trg_DEL_DBPODet logic
        
        // Prevent deletion if PO is closed
        $po = DbPO::where('NOBUKTI', $poDet->NOBUKTI)->first();
        if ($po && $po->IsClose) {
            throw new \Exception('Cannot delete PODET: PO is already closed');
        }
        
        // Prevent deletion if item has been received
        if ($poDet->QntBatal > 0) {
            throw new \Exception('Cannot delete PODET: Item has been partially received');
        }

        Log::info('PODET deleting', [
            'NOBUKTI' => $poDet->NOBUKTI,
            'KODEBRG' => $poDet->KODEBRG,
            'QNT' => $poDet->QNT
        ]);
    }

    public function deleted(DbPODET $poDet)
    {
        try {
            DB::transaction(function () use ($poDet) {
                // Update total pada header setelah item dihapus
                $this->updatePOTotal($poDet->NOBUKTI);
                
                // Check if PO still has details
                $remainingDetails = DbPODET::where('NOBUKTI', $poDet->NOBUKTI)->count();
                if ($remainingDetails == 0) {
                    DbPO::where('NOBUKTI', $poDet->NOBUKTI)
                        ->update(['isAut' => false]);
                }
            });
            
            Log::info('PODET deleted - PO total updated', [
                'NOBUKTI' => $poDet->NOBUKTI,
                'KODEBRG' => $poDet->KODEBRG
            ]);
            
        } catch (\Exception $e) {
            Log::error('PODET deleted - update failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $poDet->NOBUKTI
            ]);
        }
    }

    private function updatePOTotal($nobukti)
    {
        // Calculate and update total on DBPO header
        $totals = DbPODET::where('NOBUKTI', $nobukti)
                         ->selectRaw('
                             SUM(SUBTOTAL) as total_subtotal,
                             SUM(NDPP) as total_dpp,
                             SUM(NPPN) as total_ppn,
                             SUM(NNET) as total_net
                         ')
                         ->first();
        
        DbPO::where('NOBUKTI', $nobukti)->update([
            'NILAIDPP' => $totals->total_dpp ?? 0,
            'NILAIPPN' => $totals->total_ppn ?? 0,
            'NILAINET' => $totals->total_net ?? 0
        ]);
    }
}