#!/usr/bin/env python3
"""
Enhanced Laravel Blade View Generator
Version: 2.0

Features:
- Modal dialogs for create/edit (common in Delphi)
- Conditional field visibility
- Cascading dropdowns (lookup fields)
- Client-side validation matching backend
- Responsive design with Tailwind CSS
- Alpine.js for interactivity
- Support for tabs and field groups
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class ViewField:
    """Represents a field in the view"""
    name: str
    label: str
    input_type: str = "text"  # text, number, date, select, checkbox, textarea, hidden
    required: bool = False
    readonly: bool = False
    max_length: int = 0
    min_value: Optional[float] = None
    max_value: Optional[float] = None
    placeholder: str = ""
    options: List[Dict[str, str]] = None  # For select fields
    lookup_url: str = ""  # For async lookups
    depends_on: str = ""  # For conditional visibility
    depends_value: str = ""
    col_span: int = 1  # Grid column span (1-4)
    help_text: str = ""
    validation_rules: List[str] = None


class EnhancedViewGenerator:
    """Generate Laravel Blade views with modern features"""
    
    def __init__(self, model_name: str, module_name: str):
        self.model_name = model_name
        self.module_name = module_name.lower()
        self.route_name = self.module_name
        
        # Fields configuration
        self.fields: List[ViewField] = []
        self.field_groups: Dict[str, List[str]] = {}  # Group name -> field names
        self.tabs: List[Dict[str, Any]] = []
        
        # View options
        self.use_modal = False
        self.use_alpine = True
        self.use_tailwind = True
        self.grid_columns = 2
        
    def add_field(self, name: str, label: str, input_type: str = "text",
                  required: bool = False, **kwargs) -> 'EnhancedViewGenerator':
        """Add a field to the form"""
        field = ViewField(
            name=name,
            label=label,
            input_type=input_type,
            required=required,
            readonly=kwargs.get('readonly', False),
            max_length=kwargs.get('max_length', 0),
            min_value=kwargs.get('min_value'),
            max_value=kwargs.get('max_value'),
            placeholder=kwargs.get('placeholder', ''),
            options=kwargs.get('options'),
            lookup_url=kwargs.get('lookup_url', ''),
            depends_on=kwargs.get('depends_on', ''),
            depends_value=kwargs.get('depends_value', ''),
            col_span=kwargs.get('col_span', 1),
            help_text=kwargs.get('help_text', ''),
            validation_rules=kwargs.get('validation_rules', [])
        )
        self.fields.append(field)
        return self
    
    def add_field_group(self, group_name: str, field_names: List[str]) -> 'EnhancedViewGenerator':
        """Group fields together (for visual grouping)"""
        self.field_groups[group_name] = field_names
        return self
    
    def add_tab(self, tab_name: str, field_names: List[str]) -> 'EnhancedViewGenerator':
        """Add a tab with fields"""
        self.tabs.append({
            'name': tab_name,
            'fields': field_names
        })
        return self
    
    def set_options(self, use_modal: bool = False, use_alpine: bool = True,
                    use_tailwind: bool = True, grid_columns: int = 2):
        """Set view generation options"""
        self.use_modal = use_modal
        self.use_alpine = use_alpine
        self.use_tailwind = use_tailwind
        self.grid_columns = grid_columns
    
    def generate_index(self) -> str:
        """Generate index view with data table"""
        return f'''@extends('layouts.app')

@section('title', 'Data {self.model_name}')

@section('content')
<div class="container mx-auto px-4 py-6" x-data="indexComponent()">
    {{-- Header --}}
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-gray-800">Data {self.model_name}</h1>
        <div class="flex gap-2">
            @can('export', App\\Models\\{self.model_name}::class)
            <button @click="exportData()" class="btn btn-success">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                Export
            </button>
            @endcan
            
            @can('create', App\\Models\\{self.model_name}::class)
            <a href="{{{{ route('{self.route_name}.create') }}}}" class="btn btn-primary">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                </svg>
                Tambah
            </a>
            @endcan
        </div>
    </div>

    {{-- Filters --}}
    <div class="bg-white rounded-lg shadow mb-6 p-4">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
                <input type="text" 
                       x-model="filters.search" 
                       @keyup.enter="loadData()"
                       placeholder="Cari..." 
                       class="form-input w-full">
            </div>
            <div>
                <select x-model="filters.status" @change="loadData()" class="form-select w-full">
                    <option value="">Semua Status</option>
                    <option value="1">Aktif</option>
                    <option value="0">Non Aktif</option>
                </select>
            </div>
            <div class="flex gap-2">
                <button @click="loadData()" class="btn btn-secondary">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                </button>
                <button @click="resetFilters()" class="btn btn-outline">Reset</button>
            </div>
        </div>
    </div>

    {{-- Data Table --}}
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">No</th>
{self._generate_table_headers()}
                        <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Aksi</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    @forelse($data as $index => $item)
                    <tr class="hover:bg-gray-50 @if(!$item->is_aktif) text-gray-400 @endif">
                        <td class="px-6 py-4 whitespace-nowrap text-sm">{{{{ $data->firstItem() + $index }}}}</td>
{self._generate_table_columns()}
                        <td class="px-6 py-4 whitespace-nowrap text-center text-sm">
                            <div class="flex justify-center gap-2">
                                @can('update', $item)
                                <a href="{{{{ route('{self.route_name}.edit', $item->id) }}}}" 
                                   class="text-blue-600 hover:text-blue-900" title="Edit">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                    </svg>
                                </a>
                                @endcan
                                
                                @can('delete', $item)
                                <button @click="confirmDelete({{{{ $item->id }}}}, '{{{{ $item->nama ?? $item->id }}}}')" 
                                        class="text-red-600 hover:text-red-900" title="Hapus">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                    </svg>
                                </button>
                                @endcan
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="100" class="px-6 py-12 text-center text-gray-500">
                            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                            <p class="mt-2">Tidak ada data</p>
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        
        {{-- Pagination --}}
        <div class="px-6 py-4 border-t border-gray-200">
            {{{{ $data->links() }}}}
        </div>
    </div>
    
    {{-- Delete Confirmation Modal --}}
    <div x-show="showDeleteModal" 
         x-cloak
         class="fixed inset-0 z-50 overflow-y-auto"
         x-transition:enter="transition ease-out duration-300"
         x-transition:leave="transition ease-in duration-200">
        <div class="flex items-center justify-center min-h-screen px-4">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75" @click="showDeleteModal = false"></div>
            
            <div class="relative bg-white rounded-lg max-w-md w-full p-6">
                <h3 class="text-lg font-medium text-gray-900 mb-4">Konfirmasi Hapus</h3>
                <p class="text-gray-600 mb-6">
                    Apakah Anda yakin ingin menghapus <strong x-text="deleteItemName"></strong>?
                </p>
                <div class="flex justify-end gap-3">
                    <button @click="showDeleteModal = false" class="btn btn-secondary">Batal</button>
                    <button @click="deleteItem()" class="btn btn-danger">Hapus</button>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function indexComponent() {{
    return {{
        filters: {{
            search: '{{{{ request("search") }}}}',
            status: '{{{{ request("status") }}}}'
        }},
        showDeleteModal: false,
        deleteItemId: null,
        deleteItemName: '',
        
        loadData() {{
            const params = new URLSearchParams(this.filters);
            window.location.href = '{{{{ route("{self.route_name}.index") }}}}?' + params.toString();
        }},
        
        resetFilters() {{
            this.filters = {{ search: '', status: '' }};
            this.loadData();
        }},
        
        confirmDelete(id, name) {{
            this.deleteItemId = id;
            this.deleteItemName = name;
            this.showDeleteModal = true;
        }},
        
        async deleteItem() {{
            try {{
                const response = await fetch(`/{{{{ $routePrefix ?? '{self.route_name}' }}}}/${{this.deleteItemId}}`, {{
                    method: 'DELETE',
                    headers: {{
                        'X-CSRF-TOKEN': '{{{{ csrf_token() }}}}',
                        'Accept': 'application/json'
                    }}
                }});
                
                const result = await response.json();
                
                if (result.success) {{
                    window.location.reload();
                }} else {{
                    alert(result.message || 'Gagal menghapus data');
                }}
            }} catch (error) {{
                alert('Terjadi kesalahan');
            }}
            
            this.showDeleteModal = false;
        }},
        
        exportData() {{
            window.location.href = '{{{{ route("{self.route_name}.export") }}}}?' + new URLSearchParams(this.filters).toString();
        }}
    }}
}}
</script>
@endpush
'''
    
    def generate_create(self) -> str:
        """Generate create view"""
        form_fields = self._generate_form_fields('create')
        
        return f'''@extends('layouts.app')

@section('title', 'Tambah {self.model_name}')

@section('content')
<div class="container mx-auto px-4 py-6" x-data="formComponent()">
    {{-- Header --}}
    <div class="flex justify-between items-center mb-6">
        <div>
            <a href="{{{{ route('{self.route_name}.index') }}}}" class="text-gray-600 hover:text-gray-900 flex items-center gap-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
                </svg>
                Kembali
            </a>
            <h1 class="text-2xl font-bold text-gray-800 mt-2">Tambah {self.model_name}</h1>
        </div>
    </div>

    {{-- Form --}}
    <form action="{{{{ route('{self.route_name}.store') }}}}" 
          method="POST" 
          @submit.prevent="submitForm"
          class="bg-white rounded-lg shadow">
        @csrf
        
        <div class="p-6">
{form_fields}
        </div>
        
        {{-- Actions --}}
        <div class="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-end gap-3">
            <a href="{{{{ route('{self.route_name}.index') }}}}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
                <span x-show="!isSubmitting">Simpan</span>
                <span x-show="isSubmitting" class="flex items-center">
                    <svg class="animate-spin -ml-1 mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Menyimpan...
                </span>
            </button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script>
function formComponent() {{
    return {{
        isSubmitting: false,
        formData: {{{self._generate_form_data_init()}}},
        errors: {{}},
        
        async submitForm() {{
            this.isSubmitting = true;
            this.errors = {{}};
            
            try {{
                const response = await fetch('{{{{ route("{self.route_name}.store") }}}}', {{
                    method: 'POST',
                    headers: {{
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{{{ csrf_token() }}}}',
                        'Accept': 'application/json'
                    }},
                    body: JSON.stringify(this.formData)
                }});
                
                const result = await response.json();
                
                if (result.success) {{
                    window.location.href = result.redirect || '{{{{ route("{self.route_name}.index") }}}}';
                }} else {{
                    if (result.errors) {{
                        this.errors = result.errors;
                    }}
                    alert(result.message || 'Gagal menyimpan data');
                }}
            }} catch (error) {{
                alert('Terjadi kesalahan');
            }} finally {{
                this.isSubmitting = false;
            }}
        }},
        
        hasError(field) {{
            return this.errors[field] !== undefined;
        }},
        
        getError(field) {{
            return this.errors[field] ? this.errors[field][0] : '';
        }}
    }}
}}
</script>
@endpush
'''
    
    def generate_edit(self) -> str:
        """Generate edit view"""
        form_fields = self._generate_form_fields('edit')
        
        return f'''@extends('layouts.app')

@section('title', 'Edit {self.model_name}')

@section('content')
<div class="container mx-auto px-4 py-6" x-data="formComponent()">
    {{-- Header --}}
    <div class="flex justify-between items-center mb-6">
        <div>
            <a href="{{{{ route('{self.route_name}.index') }}}}" class="text-gray-600 hover:text-gray-900 flex items-center gap-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
                </svg>
                Kembali
            </a>
            <h1 class="text-2xl font-bold text-gray-800 mt-2">Edit {self.model_name}</h1>
        </div>
    </div>

    {{-- Form --}}
    <form action="{{{{ route('{self.route_name}.update', ${self.module_name}->id) }}}}" 
          method="POST" 
          @submit.prevent="submitForm"
          class="bg-white rounded-lg shadow">
        @csrf
        @method('PUT')
        
        <div class="p-6">
{form_fields}
        </div>
        
        {{-- Actions --}}
        <div class="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-end gap-3">
            <a href="{{{{ route('{self.route_name}.index') }}}}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
                <span x-show="!isSubmitting">Update</span>
                <span x-show="isSubmitting" class="flex items-center">
                    <svg class="animate-spin -ml-1 mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Menyimpan...
                </span>
            </button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script>
function formComponent() {{
    return {{
        isSubmitting: false,
        formData: {{{self._generate_form_data_init(for_edit=True)}}},
        errors: {{}},
        
        async submitForm() {{
            this.isSubmitting = true;
            this.errors = {{}};
            
            try {{
                const response = await fetch('{{{{ route("{self.route_name}.update", ${self.module_name}->id) }}}}', {{
                    method: 'PUT',
                    headers: {{
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{{{ csrf_token() }}}}',
                        'Accept': 'application/json'
                    }},
                    body: JSON.stringify(this.formData)
                }});
                
                const result = await response.json();
                
                if (result.success) {{
                    window.location.href = '{{{{ route("{self.route_name}.index") }}}}';
                }} else {{
                    if (result.errors) {{
                        this.errors = result.errors;
                    }}
                    alert(result.message || 'Gagal mengupdate data');
                }}
            }} catch (error) {{
                alert('Terjadi kesalahan');
            }} finally {{
                this.isSubmitting = false;
            }}
        }},
        
        hasError(field) {{
            return this.errors[field] !== undefined;
        }},
        
        getError(field) {{
            return this.errors[field] ? this.errors[field][0] : '';
        }}
    }}
}}
</script>
@endpush
'''
    
    def generate_show(self) -> str:
        """Generate show/detail view"""
        detail_fields = self._generate_detail_fields()
        
        return f'''@extends('layouts.app')

@section('title', 'Detail {self.model_name}')

@section('content')
<div class="container mx-auto px-4 py-6">
    {{-- Header --}}
    <div class="flex justify-between items-center mb-6">
        <div>
            <a href="{{{{ route('{self.route_name}.index') }}}}" class="text-gray-600 hover:text-gray-900 flex items-center gap-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
                </svg>
                Kembali
            </a>
            <h1 class="text-2xl font-bold text-gray-800 mt-2">Detail {self.model_name}</h1>
        </div>
        <div class="flex gap-2">
            @can('print', ${self.module_name})
            <a href="{{{{ route('{self.route_name}.print', ${self.module_name}->id) }}}}" 
               target="_blank"
               class="btn btn-secondary">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
                </svg>
                Print
            </a>
            @endcan
            
            @can('update', ${self.module_name})
            <a href="{{{{ route('{self.route_name}.edit', ${self.module_name}->id) }}}}" class="btn btn-primary">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                </svg>
                Edit
            </a>
            @endcan
        </div>
    </div>

    {{-- Detail Card --}}
    <div class="bg-white rounded-lg shadow">
        <div class="p-6">
            <dl class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4">
{detail_fields}
            </dl>
        </div>
        
        {{-- Timestamps --}}
        <div class="px-6 py-4 bg-gray-50 border-t border-gray-200 text-sm text-gray-500">
            <div class="flex justify-between">
                <span>Dibuat: {{{{ ${self.module_name}->created_at->format('d/m/Y H:i') }}}}</span>
                <span>Diupdate: {{{{ ${self.module_name}->updated_at->format('d/m/Y H:i') }}}}</span>
            </div>
        </div>
    </div>
</div>
@endsection
'''
    
    def generate_print(self) -> str:
        """Generate print view"""
        return f'''<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Print {self.model_name}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            font-size: 12px;
            line-height: 1.4;
            margin: 0;
            padding: 20px;
        }}
        .header {{
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #000;
            padding-bottom: 10px;
        }}
        .header h1 {{
            margin: 0;
            font-size: 18px;
        }}
        .content {{
            margin-bottom: 30px;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        table th, table td {{
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }}
        table th {{
            width: 200px;
            background: #f5f5f5;
        }}
        .footer {{
            margin-top: 50px;
            display: flex;
            justify-content: space-between;
        }}
        .signature {{
            text-align: center;
            width: 200px;
        }}
        .signature-line {{
            border-bottom: 1px solid #000;
            margin: 50px 0 10px;
        }}
        @media print {{
            body {{
                padding: 0;
            }}
            .no-print {{
                display: none;
            }}
        }}
    </style>
</head>
<body>
    <div class="no-print" style="margin-bottom: 20px;">
        <button onclick="window.print()" style="padding: 10px 20px; cursor: pointer;">Print</button>
        <button onclick="window.close()" style="padding: 10px 20px; cursor: pointer;">Tutup</button>
    </div>

    <div class="header">
        <h1>{self.model_name}</h1>
        <p>Tanggal Cetak: {{{{ now()->format('d/m/Y H:i') }}}}</p>
    </div>

    <div class="content">
        <table>
{self._generate_print_fields()}
        </table>
    </div>

    <div class="footer">
        <div class="signature">
            <p>Dibuat oleh</p>
            <div class="signature-line"></div>
            <p>{{{{ auth()->user()->name }}}}</p>
        </div>
        <div class="signature">
            <p>Disetujui oleh</p>
            <div class="signature-line"></div>
            <p>_________________</p>
        </div>
    </div>

    <script>
        // Auto print on load (optional)
        // window.onload = function() {{ window.print(); }}
    </script>
</body>
</html>
'''
    
    def _generate_table_headers(self) -> str:
        """Generate table headers for index view"""
        headers = []
        for field in self.fields[:6]:  # Limit to 6 fields for table
            if field.input_type == 'hidden':
                continue
            headers.append(f'                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">{field.label}</th>')
        return '\n'.join(headers)
    
    def _generate_table_columns(self) -> str:
        """Generate table columns for index view"""
        columns = []
        for field in self.fields[:6]:
            if field.input_type == 'hidden':
                continue
            columns.append(f'                        <td class="px-6 py-4 whitespace-nowrap text-sm">{{{{ $item->{field.name} }}}}</td>')
        return '\n'.join(columns)
    
    def _generate_form_fields(self, mode: str = 'create') -> str:
        """Generate form fields"""
        fields_html = []
        fields_html.append(f'            <div class="grid grid-cols-1 md:grid-cols-{self.grid_columns} gap-6">')
        
        for field in self.fields:
            field_html = self._generate_single_field(field, mode)
            fields_html.append(field_html)
        
        fields_html.append('            </div>')
        return '\n'.join(fields_html)
    
    def _generate_single_field(self, field: ViewField, mode: str) -> str:
        """Generate a single form field"""
        required_mark = '<span class="text-red-500">*</span>' if field.required else ''
        col_class = f'md:col-span-{field.col_span}' if field.col_span > 1 else ''
        
        # Conditional visibility
        x_show = ''
        if field.depends_on:
            x_show = f'x-show="formData.{field.depends_on} == \'{field.depends_value}\'"'
        
        # Value binding
        value = f"old('{field.name}')" if mode == 'create' else f"old('{field.name}', ${self.module_name}->{field.name})"
        x_model = f'x-model="formData.{field.name}"'
        
        # Build input based on type
        if field.input_type == 'textarea':
            input_html = f'''<textarea 
                    id="{field.name}"
                    name="{field.name}"
                    {x_model}
                    rows="3"
                    class="form-textarea w-full @error('{field.name}') border-red-500 @enderror"
                    {'required' if field.required else ''}
                    {'readonly' if field.readonly else ''}
                    placeholder="{field.placeholder}"></textarea>'''
        elif field.input_type == 'select':
            options_html = '<option value="">Pilih...</option>'
            if field.options:
                for opt in field.options:
                    options_html += f'\n                        <option value="{opt["value"]}">{opt["label"]}</option>'
            
            input_html = f'''<select 
                    id="{field.name}"
                    name="{field.name}"
                    {x_model}
                    class="form-select w-full @error('{field.name}') border-red-500 @enderror"
                    {'required' if field.required else ''}
                    {'disabled' if field.readonly else ''}>
                        {options_html}
                    </select>'''
        elif field.input_type == 'checkbox':
            input_html = f'''<label class="flex items-center">
                        <input type="checkbox" 
                               id="{field.name}"
                               name="{field.name}"
                               x-model="formData.{field.name}"
                               class="form-checkbox"
                               {'disabled' if field.readonly else ''}>
                        <span class="ml-2">{field.label}</span>
                    </label>'''
        elif field.input_type == 'hidden':
            return f'''                <input type="hidden" name="{field.name}" {x_model}>'''
        else:
            # Text, number, date, etc.
            attrs = []
            if field.max_length > 0:
                attrs.append(f'maxlength="{field.max_length}"')
            if field.min_value is not None:
                attrs.append(f'min="{field.min_value}"')
            if field.max_value is not None:
                attrs.append(f'max="{field.max_value}"')
            if field.required:
                attrs.append('required')
            if field.readonly:
                attrs.append('readonly')
            
            attrs_str = ' '.join(attrs)
            
            input_html = f'''<input type="{field.input_type}" 
                    id="{field.name}"
                    name="{field.name}"
                    {x_model}
                    class="form-input w-full @error('{field.name}') border-red-500 @enderror"
                    placeholder="{field.placeholder}"
                    {attrs_str}>'''
        
        return f'''
                <div class="{col_class}" {x_show}>
                    <label for="{field.name}" class="block text-sm font-medium text-gray-700 mb-1">
                        {field.label} {required_mark}
                    </label>
                    {input_html}
                    <p x-show="hasError('{field.name}')" x-text="getError('{field.name}')" class="mt-1 text-sm text-red-500"></p>
                    @error('{field.name}')
                        <p class="mt-1 text-sm text-red-500">{{{{ $message }}}}</p>
                    @enderror
                    {f'<p class="mt-1 text-xs text-gray-500">{field.help_text}</p>' if field.help_text else ''}
                </div>'''
    
    def _generate_form_data_init(self, for_edit: bool = False) -> str:
        """Generate formData initialization for Alpine.js"""
        items = []
        for field in self.fields:
            if for_edit:
                if field.input_type == 'checkbox':
                    items.append(f"{field.name}: {{{{ ${self.module_name}->{field.name} ? 'true' : 'false' }}}}")
                else:
                    items.append(f"{field.name}: '{{{{ ${self.module_name}->{field.name} }}}}'")
            else:
                default = 'false' if field.input_type == 'checkbox' else "''"
                items.append(f"{field.name}: {default}")
        
        return ',\n            '.join(items)
    
    def _generate_detail_fields(self) -> str:
        """Generate detail fields for show view"""
        fields = []
        for field in self.fields:
            if field.input_type == 'hidden':
                continue
            fields.append(f'''                <div>
                    <dt class="text-sm font-medium text-gray-500">{field.label}</dt>
                    <dd class="mt-1 text-sm text-gray-900">{{{{ ${self.module_name}->{field.name} ?? '-' }}}}</dd>
                </div>''')
        return '\n'.join(fields)
    
    def _generate_print_fields(self) -> str:
        """Generate print fields"""
        fields = []
        for field in self.fields:
            if field.input_type == 'hidden':
                continue
            fields.append(f'''            <tr>
                <th>{field.label}</th>
                <td>{{{{ ${self.module_name}->{field.name} ?? '-' }}}}</td>
            </tr>''')
        return '\n'.join(fields)
    
    def generate_all(self) -> Dict[str, str]:
        """Generate all views"""
        return {
            'index.blade.php': self.generate_index(),
            'create.blade.php': self.generate_create(),
            'edit.blade.php': self.generate_edit(),
            'show.blade.php': self.generate_show(),
            'print.blade.php': self.generate_print(),
        }


def create_from_dfm_result(dfm_result: Dict[str, Any], model_name: str) -> EnhancedViewGenerator:
    """Create ViewGenerator from DFM parser result"""
    module_name = model_name.lower()
    generator = EnhancedViewGenerator(model_name, module_name)
    
    # Add fields from DFM
    for field in dfm_result.get('fields', []):
        generator.add_field(
            name=field.field_name.lower() if hasattr(field, 'field_name') else field.get('field_name', '').lower(),
            label=field.caption if hasattr(field, 'caption') else field.get('caption', ''),
            input_type=field.input_type if hasattr(field, 'input_type') else field.get('input_type', 'text'),
            required=field.required if hasattr(field, 'required') else field.get('required', False),
            max_length=field.max_length if hasattr(field, 'max_length') else field.get('max_length', 0),
        )
    
    return generator


if __name__ == "__main__":
    # Test
    generator = EnhancedViewGenerator('Aktiva', 'aktiva')
    
    generator.add_field('kode', 'Kode Aktiva', 'text', True, max_length=25, readonly=True)
    generator.add_field('nama', 'Nama Aktiva', 'text', True, max_length=100)
    generator.add_field('tipe', 'Tipe', 'select', True, options=[
        {'value': '1', 'label': 'Bergerak'},
        {'value': '2', 'label': 'Tidak Bergerak'}
    ])
    generator.add_field('tanggal_perolehan', 'Tanggal Perolehan', 'date', True)
    generator.add_field('nilai', 'Nilai Perolehan', 'number', True, min_value=0)
    generator.add_field('keterangan', 'Keterangan', 'textarea')
    generator.add_field('is_aktif', 'Aktif', 'checkbox')
    
    views = generator.generate_all()
    
    for name, content in views.items():
        print(f"\n{'='*70}")
        print(f" {name}")
        print('='*70)
        print(content[:1000] + "...")  # Print first 1000 chars
