{{--
    Reusable DataTable Component

    Usage:
    <x-data-table
        :columns="$columns"
        :data="$data"
        :exportable="true"
        :searchable="true"
        table-id="users-table"
        class="table-striped"
    />
--}}

@props([
    'columns' => [],
    'data' => [],
    'tableId' => 'data-table',
    'exportable' => false,
    'searchable' => true,
    'pageLength' => 25,
    'class' => ''
])

<div class="table-container">
    @if($searchable)
    <div class="row mb-3">
        <div class="col-md-6">
            <div class="dataTables_length">
                <label>Show
                    <select name="{{ $tableId }}_length" class="form-select form-select-sm d-inline w-auto">
                        <option value="10">10</option>
                        <option value="25" {{ $pageLength == 25 ? 'selected' : '' }}>25</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                        <option value="-1">All</option>
                    </select> entries
                </label>
            </div>
        </div>
        <div class="col-md-6">
            <div class="dataTables_filter text-end">
                <label>Search:
                    <input type="search" class="form-control form-control-sm d-inline w-auto" placeholder="Search...">
                </label>
            </div>
        </div>
    </div>
    @endif

    <div class="table-responsive">
        <table
            id="{{ $tableId }}"
            class="table table-hover data-table {{ $class }}"
            data-table-auto="true"
            @if($exportable) data-export="true" @endif
            data-page-length="{{ $pageLength }}"
        >
            <thead>
                <tr>
                    @foreach($columns as $column)
                    <th
                        @if(isset($column['width'])) style="width: {{ $column['width'] }}" @endif
                        @if(isset($column['class'])) class="{{ $column['class'] }}" @endif
                        @if(isset($column['sortable']) && !$column['sortable']) data-orderable="false" @endif
                    >
                        {{ $column['title'] }}
                    </th>
                    @endforeach
                </tr>
            </thead>
            <tbody>
                @forelse($data as $row)
                <tr>
                    @foreach($columns as $column)
                    <td @if(isset($column['class'])) class="{{ $column['class'] }}" @endif>
                        @if(isset($column['render']))
                            {!! $column['render']($row) !!}
                        @else
                            {{ data_get($row, $column['data'], '-') }}
                        @endif
                    </td>
                    @endforeach
                </tr>
                @empty
                <tr>
                    <td colspan="{{ count($columns) }}" class="text-center text-muted py-4">
                        <i class="fas fa-inbox fa-2x mb-2"></i><br>
                        No data available
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

{{-- External JavaScript for clean architecture --}}
@once
    @push('scripts')
        <script src="{{ asset('js/components/data-table.js') }}"></script>
    @endpush
@endonce