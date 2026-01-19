#!/usr/bin/env python3
"""
Laravel Blade View Generator
Author: Migration Tool
Purpose: Generate Laravel Blade views from Delphi forms
"""

from typing import List, Dict, Any

class LaravelViewGenerator:
    """Generate Laravel Blade views"""
    
    def __init__(self, model_name: str, table_name: str, fields: List[Dict[str, Any]]):
        self.model_name = model_name
        self.table_name = table_name
        self.fields = fields
        
    def generate_index_view(self) -> str:
        """Generate index/list view"""
        
        # Build table headers
        headers = []
        columns = []
        
        for field in self.fields:
            if field.get('visible', True):
                caption = field.get('caption', field.get('field_name', ''))
                field_name = field.get('field_name', '').lower()
                
                headers.append(f"<th>{caption}</th>")
                columns.append(f"<td>{{{{ $item->{field_name} }}}}</td>")
        
        headers_str = "\n                        ".join(headers)
        columns_str = "\n                            ".join(columns)
        
        view_code = f"""@extends('layouts.app')

@section('title', '{self.model_name} - Data Master')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Master {self.model_name}</h3>
                    <div class="card-tools">
                        @can('create', App\\Models\\{self.model_name}::class)
                        <a href="{{{{ route('{self.table_name}.create') }}}}" class="btn btn-primary btn-sm">
                            <i class="fas fa-plus"></i> Tambah
                        </a>
                        @endcan
                        
                        @can('export', App\\Models\\{self.model_name}::class)
                        <button id="btnExport" class="btn btn-success btn-sm">
                            <i class="fas fa-file-excel"></i> Export Excel
                        </button>
                        @endcan
                        
                        <button id="btnRefresh" class="btn btn-info btn-sm">
                            <i class="fas fa-sync"></i> Refresh
                        </button>
                    </div>
                </div>
                
                <div class="card-body">
                    <!-- Filter Section -->
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <div class="input-group">
                                <input type="text" id="searchInput" class="form-control" placeholder="Cari data...">
                                <div class="input-group-append">
                                    <button class="btn btn-primary" id="btnSearch">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <select id="filterStatus" class="form-control">
                                <option value="">Semua</option>
                                <option value="aktif">Aktif</option>
                                <option value="nonaktif">Non Aktif</option>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Data Table -->
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-hover" id="dataTable">
                            <thead class="thead-dark">
                                <tr>
                                    <th width="50">No</th>
                                    {headers_str}
                                    <th width="150">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($data as $index => $item)
                                <tr class="{{{{ $item->isaktif == 0 ? 'text-danger' : '' }}}}">
                                    <td>{{{{ $data->firstItem() + $index }}}}</td>
                                    {columns_str}
                                    <td>
                                        @can('update', $item)
                                        <a href="{{{{ route('{self.table_name}.edit', $item->id) }}}}" 
                                           class="btn btn-sm btn-warning">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                        @endcan
                                        
                                        @can('delete', $item)
                                        <button class="btn btn-sm btn-danger btnDelete" 
                                                data-id="{{{{ $item->id }}}}"
                                                data-nama="{{{{ $item->namabrg }}}}">
                                            <i class="fas fa-trash"></i> Hapus
                                        </button>
                                        @endcan
                                    </td>
                                </tr>
                                @empty
                                <tr>
                                    <td colspan="{{{{ count($headers) + 2 }}}}" class="text-center">
                                        Tidak ada data
                                    </td>
                                </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination -->
                    <div class="mt-3">
                        {{{{ $data->links() }}}}
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {{
    // Search functionality
    $('#btnSearch').on('click', function() {{
        let search = $('#searchInput').val();
        let status = $('#filterStatus').val();
        
        window.location.href = '{{{{ route("{self.table_name}.index") }}}}' + 
            '?search=' + search + '&status=' + status;
    }});
    
    // Enter key search
    $('#searchInput').on('keypress', function(e) {{
        if (e.which === 13) {{
            $('#btnSearch').click();
        }}
    }});
    
    // Filter status change
    $('#filterStatus').on('change', function() {{
        $('#btnSearch').click();
    }});
    
    // Refresh button
    $('#btnRefresh').on('click', function() {{
        window.location.reload();
    }});
    
    // Export button
    $('#btnExport').on('click', function() {{
        window.location.href = '{{{{ route("{self.table_name}.export") }}}}';
    }});
    
    // Delete button
    $('.btnDelete').on('click', function() {{
        let id = $(this).data('id');
        let nama = $(this).data('nama');
        
        if (confirm('Anda yakin akan menghapus data "' + nama + '" ?')) {{
            $.ajax({{
                url: '{{{{ route("{self.table_name}.destroy", ":id") }}}}'.replace(':id', id),
                type: 'DELETE',
                data: {{
                    _token: '{{{{ csrf_token() }}}}'
                }},
                success: function(response) {{
                    if (response.success) {{
                        alert(response.message);
                        window.location.reload();
                    }} else {{
                        alert(response.message);
                    }}
                }},
                error: function(xhr) {{
                    alert('Terjadi kesalahan saat menghapus data');
                }}
            }});
        }}
    }});
}});
</script>
@endpush
"""
        return view_code
    
    def generate_create_view(self) -> str:
        """Generate create form view"""
        
        # Build form fields
        form_fields = []
        
        for field in self.fields:
            field_name = field.get('field_name', '').lower()
            caption = field.get('caption', field.get('field_name', ''))
            data_type = field.get('data_type', 'String')
            required = field.get('required', False)
            
            if field_name in ['id', 'created_at', 'updated_at', 'deleted_at']:
                continue
            
            required_attr = 'required' if required else ''
            required_label = '<span class="text-danger">*</span>' if required else ''
            
            if data_type in ['Integer', 'BCD', 'Float', 'Word']:
                input_type = 'number'
                step = 'step="0.01"' if data_type in ['BCD', 'Float'] else ''
            elif data_type == 'Boolean':
                input_type = 'checkbox'
                step = ''
            elif data_type in ['DateTime', 'Date']:
                input_type = 'date'
                step = ''
            else:
                input_type = 'text'
                step = ''
            
            form_field = f"""
                    <div class="form-group">
                        <label for="{field_name}">{caption} {required_label}</label>
                        <input type="{input_type}" 
                               class="form-control @error('{field_name}') is-invalid @enderror" 
                               id="{field_name}" 
                               name="{field_name}" 
                               value="{{{{ old('{field_name}') }}}}"
                               {step}
                               {required_attr}>
                        @error('{field_name}')
                            <div class="invalid-feedback">{{{{ $message }}}}</div>
                        @enderror
                    </div>"""
            
            form_fields.append(form_field)
        
        form_fields_str = "\n".join(form_fields)
        
        view_code = f"""@extends('layouts.app')

@section('title', 'Tambah {self.model_name}')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Tambah {self.model_name}</h3>
                    <div class="card-tools">
                        <a href="{{{{ route('{self.table_name}.index') }}}}" class="btn btn-secondary btn-sm">
                            <i class="fas fa-arrow-left"></i> Kembali
                        </a>
                    </div>
                </div>
                
                <form action="{{{{ route('{self.table_name}.store') }}}}" method="POST" id="formCreate">
                    @csrf
                    
                    <div class="card-body">
                        {form_fields_str}
                    </div>
                    
                    <div class="card-footer">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Simpan
                        </button>
                        <a href="{{{{ route('{self.table_name}.index') }}}}" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Batal
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {{
    $('#formCreate').on('submit', function(e) {{
        e.preventDefault();
        
        $.ajax({{
            url: $(this).attr('action'),
            type: 'POST',
            data: $(this).serialize(),
            success: function(response) {{
                if (response.success) {{
                    alert(response.message);
                    window.location.href = '{{{{ route("{self.table_name}.index") }}}}';
                }} else {{
                    alert(response.message);
                }}
            }},
            error: function(xhr) {{
                if (xhr.status === 422) {{
                    let errors = xhr.responseJSON.errors;
                    let errorMessage = 'Validasi gagal:\\n';
                    
                    $.each(errors, function(key, value) {{
                        errorMessage += '- ' + value[0] + '\\n';
                    }});
                    
                    alert(errorMessage);
                }} else {{
                    alert('Terjadi kesalahan saat menyimpan data');
                }}
            }}
        }});
    }});
}});
</script>
@endpush
"""
        return view_code
    
    def generate_edit_view(self) -> str:
        """Generate edit form view (similar to create but with existing data)"""
        
        # Build form fields
        form_fields = []
        
        for field in self.fields:
            field_name = field.get('field_name', '').lower()
            caption = field.get('caption', field.get('field_name', ''))
            data_type = field.get('data_type', 'String')
            required = field.get('required', False)
            
            if field_name in ['id', 'created_at', 'updated_at', 'deleted_at']:
                continue
            
            required_attr = 'required' if required else ''
            required_label = '<span class="text-danger">*</span>' if required else ''
            
            if data_type in ['Integer', 'BCD', 'Float', 'Word']:
                input_type = 'number'
                step = 'step="0.01"' if data_type in ['BCD', 'Float'] else ''
            elif data_type == 'Boolean':
                input_type = 'checkbox'
                step = ''
            elif data_type in ['DateTime', 'Date']:
                input_type = 'date'
                step = ''
            else:
                input_type = 'text'
                step = ''
            
            form_field = f"""
                    <div class="form-group">
                        <label for="{field_name}">{caption} {required_label}</label>
                        <input type="{input_type}" 
                               class="form-control @error('{field_name}') is-invalid @enderror" 
                               id="{field_name}" 
                               name="{field_name}" 
                               value="{{{{ old('{field_name}', $data->{field_name}) }}}}"
                               {step}
                               {required_attr}>
                        @error('{field_name}')
                            <div class="invalid-feedback">{{{{ $message }}}}</div>
                        @enderror
                    </div>"""
            
            form_fields.append(form_field)
        
        form_fields_str = "\n".join(form_fields)
        
        view_code = f"""@extends('layouts.app')

@section('title', 'Edit {self.model_name}')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Edit {self.model_name}</h3>
                    <div class="card-tools">
                        <a href="{{{{ route('{self.table_name}.index') }}}}" class="btn btn-secondary btn-sm">
                            <i class="fas fa-arrow-left"></i> Kembali
                        </a>
                    </div>
                </div>
                
                <form action="{{{{ route('{self.table_name}.update', $data->id) }}}}" method="POST" id="formEdit">
                    @csrf
                    @method('PUT')
                    
                    <div class="card-body">
                        {form_fields_str}
                    </div>
                    
                    <div class="card-footer">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update
                        </button>
                        <a href="{{{{ route('{self.table_name}.index') }}}}" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Batal
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {{
    $('#formEdit').on('submit', function(e) {{
        e.preventDefault();
        
        $.ajax({{
            url: $(this).attr('action'),
            type: 'PUT',
            data: $(this).serialize(),
            success: function(response) {{
                if (response.success) {{
                    alert(response.message);
                    window.location.href = '{{{{ route("{self.table_name}.index") }}}}';
                }} else {{
                    alert(response.message);
                }}
            }},
            error: function(xhr) {{
                if (xhr.status === 422) {{
                    let errors = xhr.responseJSON.errors;
                    let errorMessage = 'Validasi gagal:\\n';
                    
                    $.each(errors, function(key, value) {{
                        errorMessage += '- ' + value[0] + '\\n';
                    }});
                    
                    alert(errorMessage);
                }} else {{
                    alert('Terjadi kesalahan saat mengupdate data');
                }}
            }}
        }});
    }});
}});
</script>
@endpush
"""
        return view_code

if __name__ == "__main__":
    # Test the generator
    sample_fields = [
        {'field_name': 'KodeBrg', 'caption': 'Kode Barang', 'data_type': 'String', 'visible': True, 'required': True},
        {'field_name': 'NamaBrg', 'caption': 'Nama Barang', 'data_type': 'String', 'visible': True, 'required': True},
        {'field_name': 'Sat1', 'caption': 'Satuan 1', 'data_type': 'String', 'visible': True},
    ]
    
    generator = LaravelViewGenerator('Barang', 'barang', sample_fields)
    print("=== INDEX VIEW ===")
    print(generator.generate_index_view())
