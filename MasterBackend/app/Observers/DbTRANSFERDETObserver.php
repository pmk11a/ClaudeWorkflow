<?php

namespace App\Observers;

use App\Models\DbTRANSFERDET;
use App\Models\DbTRANSFER;
use App\Models\DbSTOCKBRG;
use App\Models\DbBARANG;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class DbTRANSFERDETObserver
{
    public function creating(DbTRANSFERDET $transferDet)
    {
        // Replicate trigger: TRI_ADD_DBTRANSFERDET logic
        Log::info('TRANSFERDET creating', [
            'NOBUKTI' => $transferDet->NOBUKTI,
            'KODEBRG' => $transferDet->KODEBRG,
            'QNT' => $transferDet->QNT
        ]);
        
        // Auto-generate URUT if not provided
        if (empty($transferDet->URUT)) {
            $maxUrut = DbTRANSFERDET::where('NOBUKTI', $transferDet->NOBUKTI)
                                   ->max('URUT');
            $transferDet->URUT = ($maxUrut ?? 0) + 1;
        }
        
        // Get item name from master
        if (empty($transferDet->NamaBrg) && !empty($transferDet->KODEBRG)) {
            $barang = DbBARANG::where('KODEBRG', $transferDet->KODEBRG)->first();
            if ($barang) {
                $transferDet->NamaBrg = $barang->NAMABRG;
            }
        }
        
        // Set default values
        $transferDet->QntBatal = $transferDet->QntBatal ?? 0;
        $transferDet->Isbatal = $transferDet->Isbatal ?? false;
    }

    public function created(DbTRANSFERDET $transferDet)
    {
        try {
            DB::transaction(function () use ($transferDet) {
                $transfer = DbTRANSFER::where('NOBUKTI', $transferDet->NOBUKTI)->first();
                
                if ($transfer) {
                    // Check stock availability di gudang asal
                    $sourceStock = DbSTOCKBRG::where('KODEBRG', $transferDet->KODEBRG)
                                             ->where('KODEGDG', $transfer->KODEGDG)
                                             ->first();
                    
                    if (!$sourceStock || $sourceStock->QTY < $transferDet->QNT) {
                        throw new \Exception('Insufficient stock in source warehouse');
                    }
                    
                    // Kurangi stock di gudang asal
                    $sourceStock->decrement('QTY', $transferDet->QNT);
                    
                    // Tambah stock di gudang tujuan
                    $targetStock = DbSTOCKBRG::firstOrCreate([
                        'KODEBRG' => $transferDet->KODEBRG,
                        'KODEGDG' => $transfer->KODEGDGTUJ
                    ], [
                        'QTY' => 0,
                        'NAMABRG' => $transferDet->NamaBrg
                    ]);
                    
                    $targetStock->increment('QTY', $transferDet->QNT);
                }
            });
            
            Log::info('TRANSFERDET created - stock moved', [
                'NOBUKTI' => $transferDet->NOBUKTI,
                'KODEBRG' => $transferDet->KODEBRG,
                'QNT' => $transferDet->QNT
            ]);
            
        } catch (\Exception $e) {
            Log::error('TRANSFERDET created - stock movement failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $transferDet->NOBUKTI
            ]);
            throw $e; // Re-throw to prevent creation
        }
    }

    public function updating(DbTRANSFERDET $transferDet)
    {
        // Replicate trigger: TRI_UPD_DBTRANSFERDET logic
        
        // Prevent update if transfer is closed
        $transfer = DbTRANSFER::where('NOBUKTI', $transferDet->NOBUKTI)->first();
        if ($transfer && $transfer->IsClose) {
            throw new \Exception('Cannot update TRANSFERDET: Transfer is already closed');
        }
        
        $oldQty = $transferDet->getOriginal('QNT');
        $newQty = $transferDet->QNT;
        
        if ($oldQty != $newQty) {
            Log::info('TRANSFERDET quantity changing', [
                'NOBUKTI' => $transferDet->NOBUKTI,
                'KODEBRG' => $transferDet->KODEBRG,
                'old_qty' => $oldQty,
                'new_qty' => $newQty
            ]);
        }
    }

    public function updated(DbTRANSFERDET $transferDet)
    {
        // Update stock jika quantity berubah
        $oldQty = $transferDet->getOriginal('QNT');
        $newQty = $transferDet->QNT;
        
        if ($oldQty != $newQty) {
            try {
                DB::transaction(function () use ($transferDet, $oldQty, $newQty) {
                    $transfer = DbTRANSFER::where('NOBUKTI', $transferDet->NOBUKTI)->first();
                    $qtyDiff = $newQty - $oldQty;
                    
                    if ($transfer) {
                        // Adjust stock di gudang asal
                        $sourceStock = DbSTOCKBRG::where('KODEBRG', $transferDet->KODEBRG)
                                                 ->where('KODEGDG', $transfer->KODEGDG)
                                                 ->first();
                        
                        if ($sourceStock) {
                            // Jika qty naik, kurangi stock sumber lebih banyak
                            // Jika qty turun, kembalikan stock ke sumber
                            $sourceStock->decrement('QTY', $qtyDiff);
                        }
                        
                        // Adjust stock di gudang tujuan
                        $targetStock = DbSTOCKBRG::where('KODEBRG', $transferDet->KODEBRG)
                                                 ->where('KODEGDG', $transfer->KODEGDGTUJ)
                                                 ->first();
                        
                        if ($targetStock) {
                            $targetStock->increment('QTY', $qtyDiff);
                        }
                    }
                });
                
            } catch (\Exception $e) {
                Log::error('TRANSFERDET updated - stock adjustment failed', [
                    'error' => $e->getMessage(),
                    'NOBUKTI' => $transferDet->NOBUKTI
                ]);
            }
        }
    }

    public function deleting(DbTRANSFERDET $transferDet)
    {
        // Prevent deletion if transfer is closed
        $transfer = DbTRANSFER::where('NOBUKTI', $transferDet->NOBUKTI)->first();
        if ($transfer && $transfer->IsClose) {
            throw new \Exception('Cannot delete TRANSFERDET: Transfer is already closed');
        }

        Log::info('TRANSFERDET deleting', [
            'NOBUKTI' => $transferDet->NOBUKTI,
            'KODEBRG' => $transferDet->KODEBRG,
            'QNT' => $transferDet->QNT
        ]);
    }

    public function deleted(DbTRANSFERDET $transferDet)
    {
        // Replicate trigger: TRI_DEL_DBTRANSFERDET logic
        try {
            DB::transaction(function () use ($transferDet) {
                $transfer = DbTRANSFER::where('NOBUKTI', $transferDet->NOBUKTI)->first();
                
                if ($transfer) {
                    // Kembalikan stock ke gudang asal
                    $sourceStock = DbSTOCKBRG::where('KODEBRG', $transferDet->KODEBRG)
                                             ->where('KODEGDG', $transfer->KODEGDG)
                                             ->first();
                    
                    if ($sourceStock) {
                        $sourceStock->increment('QTY', $transferDet->QNT);
                    }
                    
                    // Kurangi stock dari gudang tujuan
                    $targetStock = DbSTOCKBRG::where('KODEBRG', $transferDet->KODEBRG)
                                             ->where('KODEGDG', $transfer->KODEGDGTUJ)
                                             ->first();
                    
                    if ($targetStock) {
                        $targetStock->decrement('QTY', $transferDet->QNT);
                    }
                }
            });
            
            Log::info('TRANSFERDET deleted - stock restored', [
                'NOBUKTI' => $transferDet->NOBUKTI,
                'KODEBRG' => $transferDet->KODEBRG,
                'QNT' => $transferDet->QNT
            ]);
            
        } catch (\Exception $e) {
            Log::error('TRANSFERDET deleted - stock restoration failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $transferDet->NOBUKTI
            ]);
        }
    }
}