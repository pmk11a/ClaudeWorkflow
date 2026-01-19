#!/usr/bin/env python3
"""
Enhanced Laravel Controller Generator
Generates Controllers that use FormRequest classes and Service layer

Features:
- Uses mode-specific FormRequest classes (Store/Update)
- Injects Service for business logic
- Proper exception handling with JsonResponse
- Authorization through FormRequest
- Clean, minimal controller code
"""

from typing import List, Dict, Any, Optional


class EnhancedControllerGenerator:
    """Generate Laravel Resource Controllers with best practices"""
    
    def __init__(self, model_name: str, module_name: str):
        self.model_name = model_name
        self.module_name = module_name.lower()
        self.route_name = self.module_name
        
        # Configure which methods to generate
        self.has_soft_delete = True
        self.has_export = False
        self.has_print = False
        self.has_authorization = False
        
    def set_features(self, soft_delete: bool = True, export: bool = False, 
                     print_feature: bool = False, authorization: bool = False):
        """Configure controller features"""
        self.has_soft_delete = soft_delete
        self.has_export = export
        self.has_print = print_feature
        self.has_authorization = authorization
    
    def generate(self) -> str:
        """Generate complete Controller class"""
        
        # Build additional methods
        additional_methods = []
        
        if self.has_export:
            additional_methods.append(self._generate_export_method())
        
        if self.has_print:
            additional_methods.append(self._generate_print_method())
        
        if self.has_authorization:
            additional_methods.append(self._generate_authorize_method())
        
        if self.has_soft_delete:
            additional_methods.append(self._generate_restore_method())
        
        additional_str = '\n'.join(additional_methods)
        
        return f'''<?php

namespace App\\Http\\Controllers;

use App\\Http\\Requests\\{self.model_name}\\Store{self.model_name}Request;
use App\\Http\\Requests\\{self.model_name}\\Update{self.model_name}Request;
use App\\Models\\{self.model_name};
use App\\Services\\{self.model_name}Service;
use Exception;
use Illuminate\\Http\\JsonResponse;
use Illuminate\\Http\\Request;
use Illuminate\\View\\View;

/**
 * {self.model_name}Controller
 * 
 * Resource controller for {self.model_name} CRUD operations
 * 
 * Delphi equivalent: Frm{self.model_name} form with UpdateData(Choice:Char)
 * 
 * Authorization is handled by FormRequest classes:
 *   - Store{self.model_name}Request::authorize() → IsTambah
 *   - Update{self.model_name}Request::authorize() → IsKoreksi
 *   - destroy() uses policy → IsHapus
 * 
 * @see \\App\\Services\\{self.model_name}Service
 */
class {self.model_name}Controller extends Controller
{{
    /**
     * Create a new controller instance.
     * 
     * @param {self.model_name}Service $service
     */
    public function __construct(
        private readonly {self.model_name}Service $service
    ) {{
        $this->middleware('auth');
    }}

    /**
     * Display a listing of the resource.
     * 
     * Delphi equivalent: QuView.Open / Grid display
     */
    public function index(Request $request): View|JsonResponse
    {{
        $filters = [
            'search' => $request->get('search'),
            'is_aktif' => $request->has('is_aktif') ? (bool) $request->get('is_aktif') : null,
        ];

        $data = $this->service->getAll($filters, $request->get('per_page', 15));

        if ($request->wantsJson()) {{
            return response()->json([
                'success' => true,
                'data' => $data,
            ]);
        }}

        return view('{self.module_name}.index', compact('data', 'filters'));
    }}

    /**
     * Show the form for creating a new resource.
     * 
     * Delphi equivalent: ToolButton1Click (Tambah)
     */
    public function create(): View
    {{
        return view('{self.module_name}.create');
    }}

    /**
     * Store a newly created resource in storage.
     * 
     * Delphi equivalent: UpdateData('I') - INSERT mode
     * 
     * Authorization: Store{self.model_name}Request::authorize() checks IsTambah
     * Validation: Store{self.model_name}Request::rules()
     * 
     * @param Store{self.model_name}Request $request Validated request
     */
    public function store(Store{self.model_name}Request $request): JsonResponse
    {{
        try {{
            ${self.module_name} = $this->service->register($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil disimpan',
                'data' => ${self.module_name},
                'redirect' => route('{self.route_name}.show', ${self.module_name}->id),
            ], 201);
        }} catch (Exception $e) {{
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }}
    }}

    /**
     * Display the specified resource.
     * 
     * Delphi equivalent: TampilData(NoBukti)
     */
    public function show(string $id): View|JsonResponse
    {{
        ${self.module_name} = $this->service->find($id);

        if (request()->wantsJson()) {{
            return response()->json([
                'success' => true,
                'data' => ${self.module_name},
            ]);
        }}

        return view('{self.module_name}.show', compact('{self.module_name}'));
    }}

    /**
     * Show the form for editing the specified resource.
     * 
     * Delphi equivalent: ToolButton2Click (Koreksi)
     */
    public function edit(string $id): View
    {{
        ${self.module_name} = $this->service->find($id);

        return view('{self.module_name}.edit', compact('{self.module_name}'));
    }}

    /**
     * Update the specified resource in storage.
     * 
     * Delphi equivalent: UpdateData('U') - UPDATE mode
     * 
     * Authorization: Update{self.model_name}Request::authorize() checks IsKoreksi
     * Validation: Update{self.model_name}Request::rules()
     * 
     * @param Update{self.model_name}Request $request Validated request
     * @param string $id Record identifier
     */
    public function update(Update{self.model_name}Request $request, string $id): JsonResponse
    {{
        try {{
            ${self.module_name} = $this->service->update($id, $request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil diperbarui',
                'data' => ${self.module_name},
            ]);
        }} catch (Exception $e) {{
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }}
    }}

    /**
     * Remove the specified resource from storage.
     * 
     * Delphi equivalent: UpdateData('D') - DELETE mode
     * 
     * @param Request $request
     * @param string $id Record identifier
     */
    public function destroy(Request $request, string $id): JsonResponse
    {{
        try {{
            // Authorization via Policy
            ${self.module_name} = $this->service->find($id);
            $this->authorize('delete', ${self.module_name});

            $this->service->delete($id, $request->get('reason'));

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil dihapus',
            ]);
        }} catch (Exception $e) {{
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }}
    }}
{additional_str}
}}
'''
    
    def _generate_export_method(self) -> str:
        """Generate export method"""
        return f'''
    /**
     * Export data to Excel
     * 
     * Delphi equivalent: IsExcel permission check + Excel export
     */
    public function export(Request $request)
    {{
        $this->authorize('export', {self.model_name}::class);

        try {{
            $filters = [
                'search' => $request->get('search'),
                'is_aktif' => $request->has('is_aktif') ? (bool) $request->get('is_aktif') : null,
            ];

            // Use Laravel Excel or similar package
            // return Excel::download(new {self.model_name}Export($filters), '{self.module_name}.xlsx');

            return response()->json([
                'success' => true,
                'message' => 'Export berhasil',
            ]);
        }} catch (Exception $e) {{
            return response()->json([
                'success' => false,
                'message' => 'Gagal export: ' . $e->getMessage(),
            ], 500);
        }}
    }}
'''
    
    def _generate_print_method(self) -> str:
        """Generate print method"""
        return f'''
    /**
     * Print document
     * 
     * Delphi equivalent: IsCetak permission check + print
     */
    public function print(string $id): View
    {{
        ${self.module_name} = $this->service->find($id);
        $this->authorize('print', ${self.module_name});

        return view('{self.module_name}.print', compact('{self.module_name}'));
    }}
'''
    
    def _generate_authorize_method(self) -> str:
        """Generate authorization method"""
        return f'''
    /**
     * Authorize/approve the record
     * 
     * Delphi equivalent: Authorization workflow
     */
    public function authorize{self.model_name}(Request $request, string $id): JsonResponse
    {{
        try {{
            ${self.module_name} = $this->service->find($id);
            $this->authorize('authorize', ${self.module_name});

            // Call service authorization method
            // ${self.module_name} = $this->service->authorize($id, $request->get('level'));

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil diotorisasi',
                'data' => ${self.module_name},
            ]);
        }} catch (Exception $e) {{
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }}
    }}
'''
    
    def _generate_restore_method(self) -> str:
        """Generate restore method for soft deletes"""
        return f'''
    /**
     * Restore a soft-deleted resource.
     * 
     * @param string $id Record identifier
     */
    public function restore(string $id): JsonResponse
    {{
        try {{
            ${self.module_name} = {self.model_name}::withTrashed()->findOrFail($id);
            $this->authorize('restore', ${self.module_name});

            ${self.module_name}->restore();

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil dipulihkan',
                'data' => ${self.module_name},
            ]);
        }} catch (Exception $e) {{
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }}
    }}
'''


def create_from_parser_result(parser_result: Dict[str, Any], model_name: str) -> EnhancedControllerGenerator:
    """Create ControllerGenerator from parser result"""
    module_name = parser_result.get('unit_name', model_name)
    
    # Remove common prefixes
    for prefix in ['Frm', 'frm', 'Fr', 'fr', 'Form']:
        if module_name.startswith(prefix):
            module_name = module_name[len(prefix):]
            break
    
    generator = EnhancedControllerGenerator(model_name, module_name)
    
    # Detect features from permissions
    permissions = parser_result.get('permission_checks', [])
    perm_names = [p.name for p in permissions]
    
    generator.set_features(
        export='IsExcel' in perm_names or 'IsExport' in perm_names,
        print_feature='IsCetak' in perm_names,
    )
    
    return generator


if __name__ == "__main__":
    # Test the generator
    generator = EnhancedControllerGenerator('Aktiva', 'aktiva')
    generator.set_features(
        soft_delete=True,
        export=True,
        print_feature=True,
        authorization=True
    )
    
    print(generator.generate())
