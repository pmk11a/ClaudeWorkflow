<?php

namespace App\Observers;

use App\Models\DbKOREKSIDET;
use App\Models\DbKOREKSI;
use App\Models\DbSTOCKBRG;
use App\Models\DbBARANG;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class DbKOREKSIDETObserver
{
    public function creating(DbKOREKSIDET $koreksiDet)
    {
        // Replicate trigger: TRI_ADD_DBKOREKSIDET logic
        Log::info('KOREKSIDET creating', [
            'NOBUKTI' => $koreksiDet->NOBUKTI,
            'KODEBRG' => $koreksiDet->KODEBRG,
            'QTYREAL' => $koreksiDet->QTYREAL,
            'QTYSYSTEM' => $koreksiDet->QTYSYSTEM
        ]);
        
        // Auto-generate URUT if not provided
        if (empty($koreksiDet->URUT)) {
            $maxUrut = DbKOREKSIDET::where('NOBUKTI', $koreksiDet->NOBUKTI)
                                   ->max('URUT');
            $koreksiDet->URUT = ($maxUrut ?? 0) + 1;
        }
        
        // Get item name from master
        if (empty($koreksiDet->NamaBrg) && !empty($koreksiDet->KODEBRG)) {
            $barang = DbBARANG::where('KODEBRG', $koreksiDet->KODEBRG)->first();
            if ($barang) {
                $koreksiDet->NamaBrg = $barang->NAMABRG;
            }
        }
        
        // Calculate difference
        $koreksiDet->QTYSELISIH = $koreksiDet->QTYREAL - $koreksiDet->QTYSYSTEM;
        
        // Set default values
        $koreksiDet->Isbatal = $koreksiDet->Isbatal ?? false;
    }

    public function created(DbKOREKSIDET $koreksiDet)
    {
        try {
            DB::transaction(function () use ($koreksiDet) {
                $koreksi = DbKOREKSI::where('NOBUKTI', $koreksiDet->NOBUKTI)->first();
                
                if ($koreksi && $koreksiDet->QTYSELISIH != 0) {
                    // Update stock berdasarkan selisih
                    $stock = DbSTOCKBRG::where('KODEBRG', $koreksiDet->KODEBRG)
                                       ->where('KODEGDG', $koreksi->KODEGDG)
                                       ->first();
                    
                    if ($stock) {
                        // Adjust stock dengan selisih
                        if ($koreksiDet->QTYSELISIH > 0) {
                            // Stock real lebih besar, tambah stock
                            $stock->increment('QTY', $koreksiDet->QTYSELISIH);
                            Log::info('Stock increased', [
                                'KODEBRG' => $koreksiDet->KODEBRG,
                                'adjustment' => $koreksiDet->QTYSELISIH
                            ]);
                        } else {
                            // Stock real lebih kecil, kurangi stock
                            $stock->decrement('QTY', abs($koreksiDet->QTYSELISIH));
                            Log::info('Stock decreased', [
                                'KODEBRG' => $koreksiDet->KODEBRG,
                                'adjustment' => $koreksiDet->QTYSELISIH
                            ]);
                        }
                        
                        // Update system qty dengan real qty
                        $koreksiDet->update(['QTYSYSTEM' => $koreksiDet->QTYREAL]);
                    }
                }
            });
            
            Log::info('KOREKSIDET created - stock adjusted', [
                'NOBUKTI' => $koreksiDet->NOBUKTI,
                'KODEBRG' => $koreksiDet->KODEBRG,
                'adjustment' => $koreksiDet->QTYSELISIH
            ]);
            
        } catch (\Exception $e) {
            Log::error('KOREKSIDET created - stock adjustment failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $koreksiDet->NOBUKTI
            ]);
            throw $e;
        }
    }

    public function updating(DbKOREKSIDET $koreksiDet)
    {
        // Note: TRI_UPD_DBKOREKSIDET is DISABLED in database
        // But we still implement the logic for completeness
        
        // Prevent update if correction is closed
        $koreksi = DbKOREKSI::where('NOBUKTI', $koreksiDet->NOBUKTI)->first();
        if ($koreksi && $koreksi->IsClose) {
            throw new \Exception('Cannot update KOREKSIDET: Stock correction is already closed');
        }
        
        $oldQtyReal = $koreksiDet->getOriginal('QTYREAL');
        $newQtyReal = $koreksiDet->QTYREAL;
        $oldQtySystem = $koreksiDet->getOriginal('QTYSYSTEM');
        $newQtySystem = $koreksiDet->QTYSYSTEM;
        
        // Recalculate difference
        $koreksiDet->QTYSELISIH = $newQtyReal - $newQtySystem;
        
        if ($oldQtyReal != $newQtyReal || $oldQtySystem != $newQtySystem) {
            Log::info('KOREKSIDET data changing', [
                'NOBUKTI' => $koreksiDet->NOBUKTI,
                'KODEBRG' => $koreksiDet->KODEBRG,
                'old_real' => $oldQtyReal,
                'new_real' => $newQtyReal,
                'old_system' => $oldQtySystem,
                'new_system' => $newQtySystem,
                'new_diff' => $koreksiDet->QTYSELISIH
            ]);
        }
    }

    public function updated(DbKOREKSIDET $koreksiDet)
    {
        // Adjust stock if real quantity changed
        $oldQtyReal = $koreksiDet->getOriginal('QTYREAL');
        $newQtyReal = $koreksiDet->QTYREAL;
        $oldSelisih = $koreksiDet->getOriginal('QTYSELISIH');
        $newSelisih = $koreksiDet->QTYSELISIH;
        
        if ($oldQtyReal != $newQtyReal) {
            try {
                DB::transaction(function () use ($koreksiDet, $oldSelisih, $newSelisih) {
                    $koreksi = DbKOREKSI::where('NOBUKTI', $koreksiDet->NOBUKTI)->first();
                    
                    if ($koreksi) {
                        $stock = DbSTOCKBRG::where('KODEBRG', $koreksiDet->KODEBRG)
                                           ->where('KODEGDG', $koreksi->KODEGDG)
                                           ->first();
                        
                        if ($stock) {
                            // Reverse old adjustment
                            if ($oldSelisih > 0) {
                                $stock->decrement('QTY', $oldSelisih);
                            } elseif ($oldSelisih < 0) {
                                $stock->increment('QTY', abs($oldSelisih));
                            }
                            
                            // Apply new adjustment
                            if ($newSelisih > 0) {
                                $stock->increment('QTY', $newSelisih);
                            } elseif ($newSelisih < 0) {
                                $stock->decrement('QTY', abs($newSelisih));
                            }
                        }
                    }
                });
                
            } catch (\Exception $e) {
                Log::error('KOREKSIDET updated - stock adjustment failed', [
                    'error' => $e->getMessage(),
                    'NOBUKTI' => $koreksiDet->NOBUKTI
                ]);
            }
        }
    }

    public function deleting(DbKOREKSIDET $koreksiDet)
    {
        // Prevent deletion if correction is closed
        $koreksi = DbKOREKSI::where('NOBUKTI', $koreksiDet->NOBUKTI)->first();
        if ($koreksi && $koreksi->IsClose) {
            throw new \Exception('Cannot delete KOREKSIDET: Stock correction is already closed');
        }

        Log::info('KOREKSIDET deleting', [
            'NOBUKTI' => $koreksiDet->NOBUKTI,
            'KODEBRG' => $koreksiDet->KODEBRG,
            'QTYSELISIH' => $koreksiDet->QTYSELISIH
        ]);
    }

    public function deleted(DbKOREKSIDET $koreksiDet)
    {
        // Replicate trigger: TRI_DEL_DBKOREKSIDET logic
        try {
            DB::transaction(function () use ($koreksiDet) {
                $koreksi = DbKOREKSI::where('NOBUKTI', $koreksiDet->NOBUKTI)->first();
                
                if ($koreksi && $koreksiDet->QTYSELISIH != 0) {
                    // Reverse the stock adjustment
                    $stock = DbSTOCKBRG::where('KODEBRG', $koreksiDet->KODEBRG)
                                       ->where('KODEGDG', $koreksi->KODEGDG)
                                       ->first();
                    
                    if ($stock) {
                        // Reverse the adjustment
                        if ($koreksiDet->QTYSELISIH > 0) {
                            // Previous adjustment was increase, so decrease now
                            $stock->decrement('QTY', $koreksiDet->QTYSELISIH);
                        } else {
                            // Previous adjustment was decrease, so increase now
                            $stock->increment('QTY', abs($koreksiDet->QTYSELISIH));
                        }
                    }
                }
            });
            
            Log::info('KOREKSIDET deleted - stock adjustment reversed', [
                'NOBUKTI' => $koreksiDet->NOBUKTI,
                'KODEBRG' => $koreksiDet->KODEBRG,
                'reversed_adjustment' => -$koreksiDet->QTYSELISIH
            ]);
            
        } catch (\Exception $e) {
            Log::error('KOREKSIDET deleted - stock reversal failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $koreksiDet->NOBUKTI
            ]);
        }
    }
}