<?php

namespace App\Observers;

use App\Models\DbBELIDET;
use App\Models\DbSTOCKBRG;
use App\Models\DbBELI;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class DbBELIDETObserver
{
    public function creating(DbBELIDET $beliDet)
    {
        // Replicate trigger: TRG_Add_DBBELIDet logic
        Log::info('BELIDET creating', [
            'NOBUKTI' => $beliDet->NOBUKTI,
            'KODEBRG' => $beliDet->KODEBRG,
            'QNT' => $beliDet->QNT
        ]);
        
        // Set default values
        $beliDet->QntBatal = $beliDet->QntBatal ?? 0;
        $beliDet->Isbatal = $beliDet->Isbatal ?? false;
    }

    public function created(DbBELIDET $beliDet)
    {
        // Update stock setelah barang masuk
        try {
            DB::transaction(function () use ($beliDet) {
                // Update stock barang
                $stock = DbSTOCKBRG::where('KODEBRG', $beliDet->KODEBRG)
                                  ->where('KODEGDG', function($query) use ($beliDet) {
                                      $query->select('KodeGDG')
                                            ->from('DBBELI')
                                            ->where('NOBUKTI', $beliDet->NOBUKTI);
                                  })
                                  ->first();
                
                if ($stock) {
                    $stock->increment('QTY', $beliDet->QNT);
                    $stock->touch(); // Update timestamp
                }
                
                // Update total pada header DBBELI
                $this->updateBeliTotal($beliDet->NOBUKTI);
            });
            
            Log::info('BELIDET created - stock updated', [
                'NOBUKTI' => $beliDet->NOBUKTI,
                'KODEBRG' => $beliDet->KODEBRG
            ]);
            
        } catch (\Exception $e) {
            Log::error('BELIDET created - stock update failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $beliDet->NOBUKTI
            ]);
        }
    }

    public function updating(DbBELIDET $beliDet)
    {
        // Replicate trigger: Trg_UPD_Dbbelidet logic
        $oldQty = $beliDet->getOriginal('QNT');
        $newQty = $beliDet->QNT;
        
        if ($oldQty != $newQty) {
            Log::info('BELIDET quantity changing', [
                'NOBUKTI' => $beliDet->NOBUKTI,
                'KODEBRG' => $beliDet->KODEBRG,
                'old_qty' => $oldQty,
                'new_qty' => $newQty
            ]);
        }
    }

    public function updated(DbBELIDET $beliDet)
    {
        // Update stock jika quantity berubah
        $oldQty = $beliDet->getOriginal('QNT');
        $newQty = $beliDet->QNT;
        
        if ($oldQty != $newQty) {
            try {
                DB::transaction(function () use ($beliDet, $oldQty, $newQty) {
                    $qtyDiff = $newQty - $oldQty;
                    
                    $stock = DbSTOCKBRG::where('KODEBRG', $beliDet->KODEBRG)
                                      ->where('KODEGDG', function($query) use ($beliDet) {
                                          $query->select('KodeGDG')
                                                ->from('DBBELI')
                                                ->where('NOBUKTI', $beliDet->NOBUKTI);
                                      })
                                      ->first();
                    
                    if ($stock) {
                        $stock->increment('QTY', $qtyDiff);
                    }
                    
                    // Update total pada header
                    $this->updateBeliTotal($beliDet->NOBUKTI);
                });
                
            } catch (\Exception $e) {
                Log::error('BELIDET updated - stock update failed', [
                    'error' => $e->getMessage(),
                    'NOBUKTI' => $beliDet->NOBUKTI
                ]);
            }
        }
    }

    public function deleting(DbBELIDET $beliDet)
    {
        // Prevent deletion if already processed
        $beli = DbBELI::where('NOBUKTI', $beliDet->NOBUKTI)->first();
        if ($beli && $beli->IsClose) {
            throw new \Exception('Cannot delete BELIDET: Purchase is already closed');
        }

        Log::info('BELIDET deleting', [
            'NOBUKTI' => $beliDet->NOBUKTI,
            'KODEBRG' => $beliDet->KODEBRG,
            'QNT' => $beliDet->QNT
        ]);
    }

    public function deleted(DbBELIDET $beliDet)
    {
        // Replicate trigger: Trg_DEL_DBBELIDet logic
        try {
            DB::transaction(function () use ($beliDet) {
                // Kurangi stock karena detail dihapus
                $stock = DbSTOCKBRG::where('KODEBRG', $beliDet->KODEBRG)
                                  ->where('KODEGDG', function($query) use ($beliDet) {
                                      $query->select('KodeGDG')
                                            ->from('DBBELI')
                                            ->where('NOBUKTI', $beliDet->NOBUKTI);
                                  })
                                  ->first();
                
                if ($stock) {
                    $stock->decrement('QTY', $beliDet->QNT);
                }
                
                // Update total pada header
                $this->updateBeliTotal($beliDet->NOBUKTI);
            });
            
            Log::info('BELIDET deleted - stock updated', [
                'NOBUKTI' => $beliDet->NOBUKTI,
                'KODEBRG' => $beliDet->KODEBRG
            ]);
            
        } catch (\Exception $e) {
            Log::error('BELIDET deleted - stock update failed', [
                'error' => $e->getMessage(),
                'NOBUKTI' => $beliDet->NOBUKTI
            ]);
        }
    }

    private function updateBeliTotal($nobukti)
    {
        // Calculate and update total on DBBELI header
        $total = DbBELIDET::where('NOBUKTI', $nobukti)
                          ->sum(DB::raw('QNT * HARGA'));
        
        DbBELI::where('NOBUKTI', $nobukti)
              ->update(['NILAINET' => $total]);
    }
}