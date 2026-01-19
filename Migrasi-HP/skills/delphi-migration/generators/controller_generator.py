#!/usr/bin/env python3
"""
Laravel Controller Generator
Author: Migration Tool
Purpose: Generate Laravel controllers from Delphi form logic
"""

from typing import List, Dict, Any

class LaravelControllerGenerator:
    """Generate Laravel Resource Controllers"""
    
    def __init__(self, model_name: str, table_name: str, crud_methods: Dict[str, Any], 
                 validation_rules: List[Dict[str, Any]]):
        self.model_name = model_name
        self.table_name = table_name
        self.crud_methods = crud_methods
        self.validation_rules = validation_rules
        self.controller_name = f"{model_name}Controller"
        
    def generate(self) -> str:
        """Generate complete Laravel controller code"""
        
        controller_code = f"""<?php

namespace App\\Http\\Controllers;

use App\\Models\\{self.model_name};
use Illuminate\\Http\\Request;
use Illuminate\\Support\\Facades\\DB;
use Illuminate\\Support\\Facades\\Log;
use Illuminate\\Support\\Facades\\Validator;

class {self.controller_name} extends Controller
{{
    /**
     * Display a listing of the resource.
     *
     * @return \\Illuminate\\Http\\Response
     */
    public function index(Request $request)
    {{
        try {{
            $query = {self.model_name}::query();
            
            // Filter by status (aktif/non-aktif)
            if ($request->has('status')) {{
                $status = $request->input('status');
                if ($status === 'aktif') {{
                    $query->active();
                }} elseif ($status === 'nonaktif') {{
                    $query->inactive();
                }}
            }}
            
            // Search functionality
            if ($request->has('search')) {{
                $search = $request->input('search');
                $query->where(function($q) use ($search) {{
                    $q->where('kodebrg', 'like', "%$search%")
                      ->orWhere('namabrg', 'like', "%$search%");
                }});
            }}
            
            // Pagination
            $perPage = $request->input('per_page', 15);
            $data = $query->paginate($perPage);
            
            return response()->json([
                'success' => true,
                'data' => $data
            ]);
            
        }} catch (\\Exception $e) {{
            Log::error('Error fetching {self.table_name}: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data'
            ], 500);
        }}
    }}

    /**
     * Show the form for creating a new resource.
     *
     * @return \\Illuminate\\Http\\Response
     */
    public function create()
    {{
        return view('{self.table_name.lower()}.create');
    }}

    /**
     * Store a newly created resource in storage.
     *
     * @param  \\Illuminate\\Http\\Request  $request
     * @return \\Illuminate\\Http\\Response
     */
    public function store(Request $request)
    {{
        // Validate input
        $validator = Validator::make($request->all(), {self.model_name}::rules());
        
        if ($validator->fails()) {{
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }}
        
        DB::beginTransaction();
        
        try {{
            // Create new record
            $data = {self.model_name}::create($request->all());
            
            // Log activity
            $this->logActivity(auth()->user()->id, 'I', '{self.table_name}', '', 
                'Kode: ' . $data->kodebrg . ', Nama: ' . $data->namabrg);
            
            DB::commit();
            
            return response()->json([
                'success' => true,
                'message' => 'Data berhasil disimpan',
                'data' => $data
            ], 201);
            
        }} catch (\\Exception $e) {{
            DB::rollBack();
            Log::error('Error creating {self.table_name}: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan data: ' . $e->getMessage()
            ], 500);
        }}
    }}

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \\Illuminate\\Http\\Response
     */
    public function show($id)
    {{
        try {{
            $data = {self.model_name}::findOrFail($id);
            
            return response()->json([
                'success' => true,
                'data' => $data
            ]);
            
        }} catch (\\Exception $e) {{
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ], 404);
        }}
    }}

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \\Illuminate\\Http\\Response
     */
    public function edit($id)
    {{
        $data = {self.model_name}::findOrFail($id);
        return view('{self.table_name.lower()}.edit', compact('data'));
    }}

    /**
     * Update the specified resource in storage.
     *
     * @param  \\Illuminate\\Http\\Request  $request
     * @param  int  $id
     * @return \\Illuminate\\Http\\Response
     */
    public function update(Request $request, $id)
    {{
        // Validate input
        $validator = Validator::make($request->all(), {self.model_name}::rules());
        
        if ($validator->fails()) {{
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }}
        
        DB::beginTransaction();
        
        try {{
            $data = {self.model_name}::findOrFail($id);
            $oldData = $data->toArray();
            
            // Update record
            $data->update($request->all());
            
            // Log activity
            $this->logActivity(auth()->user()->id, 'U', '{self.table_name}', '', 
                'Kode: ' . $data->kodebrg . ', Nama: ' . $data->namabrg);
            
            DB::commit();
            
            return response()->json([
                'success' => true,
                'message' => 'Data berhasil diupdate',
                'data' => $data
            ]);
            
        }} catch (\\Exception $e) {{
            DB::rollBack();
            Log::error('Error updating {self.table_name}: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupdate data: ' . $e->getMessage()
            ], 500);
        }}
    }}

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \\Illuminate\\Http\\Response
     */
    public function destroy($id)
    {{
        DB::beginTransaction();
        
        try {{
            $data = {self.model_name}::findOrFail($id);
            $kodebrg = $data->kodebrg;
            $namabrg = $data->namabrg;
            
            // Soft delete
            $data->delete();
            
            // Log activity
            $this->logActivity(auth()->user()->id, 'D', '{self.table_name}', '', 
                'Kode: ' . $kodebrg . ', Nama: ' . $namabrg);
            
            DB::commit();
            
            return response()->json([
                'success' => true,
                'message' => 'Data berhasil dihapus'
            ]);
            
        }} catch (\\Exception $e) {{
            DB::rollBack();
            Log::error('Error deleting {self.table_name}: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus data: ' . $e->getMessage()
            ], 500);
        }}
    }}

    /**
     * Export data to Excel
     *
     * @param  \\Illuminate\\Http\\Request  $request
     * @return \\Illuminate\\Http\\Response
     */
    public function export(Request $request)
    {{
        try {{
            // Check permission
            if (!auth()->user()->hasPermission('excel')) {{
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki hak akses untuk export data'
                ], 403);
            }}
            
            // Export logic here (use Laravel Excel package)
            // return Excel::download(new {self.model_name}Export, '{self.table_name}.xlsx');
            
            return response()->json([
                'success' => true,
                'message' => 'Export berhasil'
            ]);
            
        }} catch (\\Exception $e) {{
            Log::error('Error exporting {self.table_name}: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal export data'
            ], 500);
        }}
    }}

    /**
     * Log user activity
     *
     * @param  string  $userId
     * @param  string  $activity
     * @param  string  $source
     * @param  string  $noBukti
     * @param  string  $keterangan
     * @return void
     */
    private function logActivity($userId, $activity, $source, $noBukti, $keterangan)
    {{
        try {{
            DB::table('log_activity')->insert([
                'user_id' => $userId,
                'activity' => $activity,
                'source' => $source,
                'no_bukti' => $noBukti,
                'keterangan' => $keterangan,
                'created_at' => now()
            ]);
        }} catch (\\Exception $e) {{
            Log::error('Error logging activity: ' . $e->getMessage());
        }}
    }}
}}
"""
        return controller_code

if __name__ == "__main__":
    # Test the generator
    generator = LaravelControllerGenerator(
        model_name='Barang',
        table_name='barang',
        crud_methods={},
        validation_rules=[]
    )
    print(generator.generate())
