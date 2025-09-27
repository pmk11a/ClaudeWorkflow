<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\DbAKTIVA; // Assuming this model exists
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

/**
 * AktivaController
 * Generated API controller for FrmAktiva form migration
 * Handles DBAKTIVA table operations
 */
class AktivaController extends Controller
{
    /**
     * Display a listing of aktiva records.
     */
    public function index(Request $request): JsonResponse
    {
        $query = DbAKTIVA::query();

        // Add search functionality
        if ($request->has('search')) {
            $search = $request->get('search');
            $query->where(function ($q) use ($search) {
                $q->where('KODEAKTIVA', 'like', "%{$search}%")
                  ->orWhere('NAMAAKTIVA', 'like', "%{$search}%")
                  ->orWhere('KELOMPOK', 'like', "%{$search}%");
            });
        }

        // Add filtering by kelompok if provided
        if ($request->has('kelompok')) {
            $query->where('KELOMPOK', $request->get('kelompok'));
        }

        // Order by kode aktiva
        $query->orderBy('KODEAKTIVA');

        $data = $query->paginate($request->get('per_page', 15));

        // Transform data to match React component expectations
        $transformedData = $data->map(function ($item) {
            return [
                'id' => $item->id ?? $item->KODEAKTIVA, // Use primary key or code
                'kode_aktiva' => $item->KODEAKTIVA,
                'nama_aktiva' => $item->NAMAAKTIVA,
                'kelompok' => $item->KELOMPOK,
                'nilai_perolehan' => $item->NILAIPEROLEHAN ?? $item->HARGAPEROLEHAN,
                'keterangan' => $item->KETERANGAN ?? '',
                'created_at' => $item->created_at ?? null,
                'updated_at' => $item->updated_at ?? null,
            ];
        });

        return response()->json([
            'data' => $transformedData,
            'meta' => [
                'current_page' => $data->currentPage(),
                'per_page' => $data->perPage(),
                'total' => $data->total(),
                'last_page' => $data->lastPage(),
            ]
        ]);
    }

    /**
     * Store a newly created aktiva record.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'kode_aktiva' => 'required|string|max:20|unique:DBAKTIVA,KODEAKTIVA',
            'nama_aktiva' => 'required|string|max:100',
            'kelompok' => 'nullable|string|max:50',
            'nilai_perolehan' => 'nullable|numeric|min:0',
            'keterangan' => 'nullable|string|max:500',
        ]);

        // Transform data to match database field names
        $data = [
            'KODEAKTIVA' => $validated['kode_aktiva'],
            'NAMAAKTIVA' => $validated['nama_aktiva'],
            'KELOMPOK' => $validated['kelompok'] ?? '',
            'NILAIPEROLEHAN' => $validated['nilai_perolehan'] ?? 0,
            'KETERANGAN' => $validated['keterangan'] ?? '',
        ];

        $aktiva = DbAKTIVA::create($data);

        // Transform response back to React format
        $response = [
            'id' => $aktiva->id ?? $aktiva->KODEAKTIVA,
            'kode_aktiva' => $aktiva->KODEAKTIVA,
            'nama_aktiva' => $aktiva->NAMAAKTIVA,
            'kelompok' => $aktiva->KELOMPOK,
            'nilai_perolehan' => $aktiva->NILAIPEROLEHAN,
            'keterangan' => $aktiva->KETERANGAN,
        ];

        return response()->json($response, 201);
    }

    /**
     * Display the specified aktiva record.
     */
    public function show(string $id): JsonResponse
    {
        // Try to find by ID or by KODEAKTIVA
        $aktiva = DbAKTIVA::where('id', $id)
                          ->orWhere('KODEAKTIVA', $id)
                          ->firstOrFail();

        $response = [
            'id' => $aktiva->id ?? $aktiva->KODEAKTIVA,
            'kode_aktiva' => $aktiva->KODEAKTIVA,
            'nama_aktiva' => $aktiva->NAMAAKTIVA,
            'kelompok' => $aktiva->KELOMPOK,
            'nilai_perolehan' => $aktiva->NILAIPEROLEHAN,
            'keterangan' => $aktiva->KETERANGAN ?? '',
        ];

        return response()->json($response);
    }

    /**
     * Update the specified aktiva record.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $aktiva = DbAKTIVA::where('id', $id)
                          ->orWhere('KODEAKTIVA', $id)
                          ->firstOrFail();

        $validated = $request->validate([
            'kode_aktiva' => 'required|string|max:20|unique:DBAKTIVA,KODEAKTIVA,' . $aktiva->id,
            'nama_aktiva' => 'required|string|max:100',
            'kelompok' => 'nullable|string|max:50',
            'nilai_perolehan' => 'nullable|numeric|min:0',
            'keterangan' => 'nullable|string|max:500',
        ]);

        // Transform data to match database field names
        $data = [
            'KODEAKTIVA' => $validated['kode_aktiva'],
            'NAMAAKTIVA' => $validated['nama_aktiva'],
            'KELOMPOK' => $validated['kelompok'] ?? '',
            'NILAIPEROLEHAN' => $validated['nilai_perolehan'] ?? 0,
            'KETERANGAN' => $validated['keterangan'] ?? '',
        ];

        $aktiva->update($data);

        // Transform response back to React format
        $response = [
            'id' => $aktiva->id ?? $aktiva->KODEAKTIVA,
            'kode_aktiva' => $aktiva->KODEAKTIVA,
            'nama_aktiva' => $aktiva->NAMAAKTIVA,
            'kelompok' => $aktiva->KELOMPOK,
            'nilai_perolehan' => $aktiva->NILAIPEROLEHAN,
            'keterangan' => $aktiva->KETERANGAN,
        ];

        return response()->json($response);
    }

    /**
     * Remove the specified aktiva record.
     */
    public function destroy(string $id): JsonResponse
    {
        $aktiva = DbAKTIVA::where('id', $id)
                          ->orWhere('KODEAKTIVA', $id)
                          ->firstOrFail();

        $aktiva->delete();

        return response()->json(null, 204);
    }

    /**
     * Get aktiva groups for filtering
     */
    public function getKelompok(): JsonResponse
    {
        $kelompok = DbAKTIVA::select('KELOMPOK')
                           ->whereNotNull('KELOMPOK')
                           ->where('KELOMPOK', '!=', '')
                           ->distinct()
                           ->orderBy('KELOMPOK')
                           ->pluck('KELOMPOK');

        return response()->json($kelompok);
    }
}