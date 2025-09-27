<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🔧 Admin Filter Settings - DAPEN-KA</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 30px;
            max-width: 1400px;
            margin: 0 auto;
        }

        .header {
            text-align: center;
            margin-bottom: 40px;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 20px;
        }

        .header h1 {
            color: #333;
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        .header p {
            color: #666;
            font-size: 1.1em;
        }

        .tabs {
            display: flex;
            margin-bottom: 30px;
            border-bottom: 2px solid #f0f0f0;
        }

        .tab {
            padding: 15px 30px;
            background: #f8f9fa;
            border: none;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            color: #666;
            border-radius: 10px 10px 0 0;
            margin-right: 5px;
            transition: all 0.3s ease;
        }

        .tab.active {
            background: #667eea;
            color: white;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .section {
            background: #f8f9ff;
            border: 2px solid #e1e5f2;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
        }

        .section h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.4em;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5a67d8;
            transform: translateY(-2px);
        }

        .btn-success {
            background: #48bb78;
            color: white;
        }

        .btn-success:hover {
            background: #38a169;
        }

        .btn-danger {
            background: #f56565;
            color: white;
        }

        .btn-danger:hover {
            background: #e53e3e;
        }

        .btn-secondary {
            background: #a0aec0;
            color: white;
        }

        .btn-secondary:hover {
            background: #718096;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .table th,
        .table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .table th {
            background: #667eea;
            color: white;
            font-weight: bold;
        }

        .table tr:hover {
            background: #f7fafc;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .badge-success {
            background: #c6f6d5;
            color: #22543d;
        }

        .badge-danger {
            background: #fed7d7;
            color: #742a2a;
        }

        .badge-warning {
            background: #feebc8;
            color: #744210;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 30px;
            border-radius: 15px;
            width: 80%;
            max-width: 600px;
            max-height: 80vh;
            overflow-y: auto;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }

        .modal-header h3 {
            margin: 0;
            color: #333;
        }

        .close {
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            color: #aaa;
        }

        .close:hover {
            color: #333;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .alert-success {
            background: #c6f6d5;
            color: #22543d;
            border: 1px solid #9ae6b4;
        }

        .alert-danger {
            background: #fed7d7;
            color: #742a2a;
            border: 1px solid #fc8181;
        }

        .filter-type-badge {
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
        }

        .type-text { background: #bee3f8; color: #2a4365; }
        .type-select { background: #d6f5d6; color: #22543d; }
        .type-date { background: #fbb6ce; color: #744210; }
        .type-number { background: #fad5a5; color: #744210; }

        .reports-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .report-card {
            background: white;
            border: 2px solid #e1e5f2;
            border-radius: 15px;
            padding: 20px;
            transition: all 0.3s ease;
        }

        .report-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            border-color: #667eea;
        }

        .report-code {
            background: #667eea;
            color: white;
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 10px;
        }

        .search-box {
            position: relative;
            margin-bottom: 20px;
        }

        .search-box input {
            padding-left: 40px;
        }

        .search-box::before {
            content: "🔍";
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            z-index: 10;
        }

        /* Grouped Filter Styles */
        .filter-group {
            margin-bottom: 20px;
            border: 2px solid #e1e5f2;
            border-radius: 15px;
            overflow: hidden;
            background: white;
        }

        .group-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .group-header:hover {
            background: linear-gradient(135deg, #5a67d8 0%, #6a4c93 100%);
        }

        .group-header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .group-header h4 {
            margin: 0;
            font-size: 1.2em;
            display: flex;
            align-items: center;
        }

        .toggle-icon {
            margin-right: 10px;
            transition: transform 0.3s ease;
            display: inline-block;
            font-size: 0.8em;
        }

        .toggle-icon.collapsed {
            transform: rotate(-90deg);
        }

        .report-title {
            font-weight: normal;
            font-size: 0.9em;
            opacity: 0.9;
        }

        .group-stats {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .group-stats .badge {
            font-size: 11px;
        }

        .group-stats .btn-sm {
            padding: 4px 8px;
            font-size: 11px;
        }

        .group-content {
            padding: 0;
            transition: all 0.3s ease;
            max-height: 2000px;
            overflow: hidden;
        }

        .group-content.collapsed {
            max-height: 0;
            padding: 0;
        }

        .group-table {
            margin: 0;
            border-radius: 0;
        }

        .group-table thead th {
            background: #f8f9ff;
            color: #333;
            font-size: 13px;
            padding: 12px 8px;
            border-bottom: 2px solid #e1e5f2;
        }

        .group-table tbody td {
            padding: 10px 8px;
            font-size: 13px;
            vertical-align: middle;
        }

        .group-table .btn-sm {
            padding: 4px 8px;
            font-size: 11px;
        }

        .filter-name {
            font-weight: bold;
            color: #333;
        }

        .no-filters {
            border: 2px dashed #e1e5f2;
            border-radius: 15px;
            background: #f8f9ff;
        }

        .text-center {
            text-align: center;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .group-header-content {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .group-stats {
                flex-wrap: wrap;
            }

            .group-table {
                font-size: 12px;
            }

            .group-table th,
            .group-table td {
                padding: 8px 4px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔧 Admin Filter Settings</h1>
            <p>Kelola filter untuk semua laporan dalam sistem DAPEN-KA</p>
        </div>

        <div class="tabs">
            <button class="tab active" onclick="switchTab('overview')">📊 Overview</button>
            <button class="tab" onclick="switchTab('filters')">🔧 Filter</button>
            <button class="tab" onclick="switchTab('configs')">⚙️ Config</button>
            <button class="tab" onclick="switchTab('headers')">📄 Header</button>
            <button class="tab" onclick="switchTab('columns')">📊 Kolom</button>
            <button class="tab" onclick="switchTab('groups')">📁 Group</button>
            <button class="tab" onclick="switchTab('reports')">📋 Laporan</button>
        </div>

        <!-- Overview Tab -->
        <div id="overview" class="tab-content active">
            <div class="section">
                <h3>📈 Statistik Filter</h3>
                <div class="form-row">
                    <div>
                        <h4>Total Filter: <span id="totalFilters">{{ count($filters) }}</span></h4>
                        <p>Filter aktif di seluruh sistem</p>
                    </div>
                    <div>
                        <h4>Total Laporan: <span id="totalReports">{{ count($reports) }}</span></h4>
                        <p>Laporan terdaftar di sistem</p>
                    </div>
                </div>
            </div>

            <div class="section">
                <h3>🎯 Filter per Laporan</h3>
                <div id="filterStats"></div>
            </div>
        </div>

        <!-- Filter Management Tab -->
        <div id="filters" class="tab-content">
            <div class="section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3>🔧 Daftar Filter per Laporan</h3>
                    <button class="btn btn-primary" onclick="openFilterModal()">
                        ➕ Tambah Filter Baru
                    </button>
                </div>

                <div style="display: flex; gap: 15px; align-items: center; margin-bottom: 20px;">
                    <div class="search-box" style="flex: 1;">
                        <input type="text" id="filterSearch" class="form-control" placeholder="Cari berdasarkan kode laporan, nama filter, atau tipe..." onkeyup="filterGroups()">
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="btn btn-secondary" onclick="expandAllGroups()" title="Buka Semua Group">
                            📖 Buka Semua
                        </button>
                        <button class="btn btn-secondary" onclick="collapseAllGroups()" title="Tutup Semua Group">
                            📕 Tutup Semua
                        </button>
                    </div>
                </div>

                <div id="filterGroups">
                    @php
                        $groupedFilters = collect($filters)->groupBy('KODEREPORT');
                    @endphp

                    @foreach($groupedFilters as $reportCode => $reportFilters)
                    <div class="filter-group" data-report-code="{{ $reportCode }}">
                        <div class="group-header" onclick="toggleGroup('{{ $reportCode }}')">
                            <div class="group-header-content">
                                <h4>
                                    <span class="toggle-icon" id="icon-{{ $reportCode }}">▼</span>
                                    📊 {{ $reportCode }}
                                    @php
                                        $reportTitle = collect($reports)->firstWhere('code', $reportCode)['title'] ?? 'Unknown Report';
                                    @endphp
                                    <span class="report-title">- {{ $reportTitle }}</span>
                                </h4>
                                <div class="group-stats">
                                    <span class="badge badge-success">{{ $reportFilters->count() }} Filter</span>
                                    <span class="badge badge-{{ $reportFilters->where('IS_VISIBLE', 1)->count() > 0 ? 'success' : 'danger' }}">
                                        {{ $reportFilters->where('IS_VISIBLE', 1)->count() }} Visible
                                    </span>
                                    <button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); addFilterForReport('{{ $reportCode }}')" style="margin-left: 10px;">
                                        ➕ Tambah
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="group-content" id="group-{{ $reportCode }}">
                            <table class="table group-table">
                                <thead>
                                    <tr>
                                        <th width="8%">ID</th>
                                        <th width="20%">Nama Filter</th>
                                        <th width="25%">Label</th>
                                        <th width="12%">Tipe</th>
                                        <th width="10%">Visible</th>
                                        <th width="10%">Required</th>
                                        <th width="8%">Order</th>
                                        <th width="12%">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($reportFilters->sortBy('SORT_ORDER') as $filter)
                                    <tr class="filter-row" data-filter-name="{{ strtolower($filter->FILTER_NAME) }}" data-filter-type="{{ strtolower($filter->FILTER_TYPE) }}">
                                        <td><strong>{{ $filter->ID }}</strong></td>
                                        <td>
                                            <span class="filter-name">{{ $filter->FILTER_NAME }}</span>
                                        </td>
                                        <td>{{ $filter->FILTER_LABEL }}</td>
                                        <td>
                                            <span class="filter-type-badge type-{{ $filter->FILTER_TYPE }}">
                                                {{ $filter->FILTER_TYPE }}
                                            </span>
                                        </td>
                                        <td>
                                            @if($filter->IS_VISIBLE)
                                                <span class="badge badge-success">✓ Ya</span>
                                            @else
                                                <span class="badge badge-danger">✗ Tidak</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($filter->IS_REQUIRED)
                                                <span class="badge badge-warning">⚠ Required</span>
                                            @else
                                                <span class="badge badge-success">📄 Optional</span>
                                            @endif
                                        </td>
                                        <td class="text-center">{{ $filter->SORT_ORDER }}</td>
                                        <td>
                                            <button class="btn btn-secondary btn-sm" onclick="editFilter({{ $filter->ID }})" style="margin-right: 5px;">
                                                ✏️
                                            </button>
                                            <button class="btn btn-danger btn-sm" onclick="deleteFilter({{ $filter->ID }})">
                                                🗑️
                                            </button>
                                        </td>
                                    </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
                    @endforeach

                    @if($groupedFilters->isEmpty())
                    <div class="no-filters">
                        <div style="text-align: center; padding: 40px; color: #666;">
                            <h4>📝 Belum Ada Filter</h4>
                            <p>Klik "Tambah Filter Baru" untuk membuat filter pertama</p>
                        </div>
                    </div>
                    @endif
                </div>
            </div>
        </div>

        <!-- Report Config Tab -->
        <div id="configs" class="tab-content">
            <div class="section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3>⚙️ Konfigurasi Laporan</h3>
                    <button class="btn btn-primary" onclick="openConfigModal()">
                        ➕ Tambah Config Baru
                    </button>
                </div>

                <div class="search-box">
                    <input type="text" id="configSearch" class="form-control" placeholder="Cari berdasarkan kode laporan atau tipe config..." onkeyup="filterConfigs()">
                </div>

                <table class="table" id="configsTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Kode Laporan</th>
                            <th>Tipe Config</th>
                            <th>Stored Procedure</th>
                            <th>Config JSON</th>
                            <th>Status</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($reportConfigs as $config)
                        <tr>
                            <td>{{ $config->ID }}</td>
                            <td><span class="report-code">{{ $config->KODEREPORT }}</span></td>
                            <td><span class="badge badge-success">{{ $config->CONFIG_TYPE }}</span></td>
                            <td>{{ $config->STOREDPROC ?? '-' }}</td>
                            <td>
                                <div style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">
                                    {{ Str::limit($config->CONFIG_JSON, 50) }}
                                </div>
                            </td>
                            <td>
                                @if($config->IS_ACTIVE)
                                    <span class="badge badge-success">✓ Aktif</span>
                                @else
                                    <span class="badge badge-danger">✗ Nonaktif</span>
                                @endif
                            </td>
                            <td>
                                <button class="btn btn-secondary btn-sm" onclick="editConfig({{ $config->ID }})" style="margin-right: 5px;">
                                    ✏️ Edit
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteConfig({{ $config->ID }})">
                                    🗑️ Hapus
                                </button>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Report Headers Tab -->
        <div id="headers" class="tab-content">
            <div class="section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3>📄 Header Laporan</h3>
                    <button class="btn btn-primary" onclick="openHeaderModal()">
                        ➕ Tambah Header Baru
                    </button>
                </div>

                <div class="search-box">
                    <input type="text" id="headerSearch" class="form-control" placeholder="Cari berdasarkan kode laporan atau judul..." onkeyup="filterHeaders()">
                </div>

                <table class="table" id="headersTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Kode Laporan</th>
                            <th>Judul</th>
                            <th>Subjudul</th>
                            <th>Orientasi</th>
                            <th>Ukuran</th>
                            <th>Opsi</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($reportHeaders as $header)
                        <tr>
                            <td>{{ $header->ID }}</td>
                            <td><span class="report-code">{{ $header->KODEREPORT }}</span></td>
                            <td><strong>{{ $header->TITLE }}</strong></td>
                            <td>{{ $header->SUBTITLE }}</td>
                            <td><span class="badge badge-success">{{ $header->ORIENTATION }}</span></td>
                            <td><span class="badge badge-success">{{ $header->PAGE_SIZE }}</span></td>
                            <td>
                                @if($header->SHOW_DATE)<span class="badge badge-success">📅</span>@endif
                                @if($header->SHOW_PARAMS)<span class="badge badge-success">⚙️</span>@endif
                                @if($header->SHOW_LOGO)<span class="badge badge-success">🏢</span>@endif
                            </td>
                            <td>
                                <button class="btn btn-secondary btn-sm" onclick="editHeader({{ $header->ID }})" style="margin-right: 5px;">
                                    ✏️ Edit
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteHeader({{ $header->ID }})">
                                    🗑️ Hapus
                                </button>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Report Columns Tab -->
        <div id="columns" class="tab-content">
            <div class="section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3>📊 Kolom Laporan</h3>
                    <button class="btn btn-primary" onclick="openColumnModal()">
                        ➕ Tambah Kolom Baru
                    </button>
                </div>

                <div style="display: flex; gap: 15px; align-items: center; margin-bottom: 20px;">
                    <div class="search-box" style="flex: 1;">
                        <input type="text" id="columnSearch" class="form-control" placeholder="Cari berdasarkan kode laporan, nama kolom..." onkeyup="filterColumnGroups()">
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="btn btn-secondary" onclick="expandAllColumnGroups()" title="Buka Semua Group">
                            📖 Buka Semua
                        </button>
                        <button class="btn btn-secondary" onclick="collapseAllColumnGroups()" title="Tutup Semua Group">
                            📕 Tutup Semua
                        </button>
                    </div>
                </div>

                <div id="columnGroups">
                    @php
                        $groupedColumns = collect($reportColumns)->groupBy('KODEREPORT');
                    @endphp

                    @foreach($groupedColumns as $reportCode => $reportColumns)
                    <div class="filter-group" data-report-code="{{ $reportCode }}">
                        <div class="group-header" onclick="toggleColumnGroup('{{ $reportCode }}')">
                            <div class="group-header-content">
                                <h4>
                                    <span class="toggle-icon" id="column-icon-{{ $reportCode }}">▼</span>
                                    📊 {{ $reportCode }}
                                    @php
                                        $reportTitle = collect($reports)->firstWhere('code', $reportCode)['title'] ?? 'Unknown Report';
                                    @endphp
                                    <span class="report-title">- {{ $reportTitle }}</span>
                                </h4>
                                <div class="group-stats">
                                    <span class="badge badge-success">{{ $reportColumns->count() }} Kolom</span>
                                    <span class="badge badge-{{ $reportColumns->where('IS_VISIBLE', 1)->count() > 0 ? 'success' : 'danger' }}">
                                        {{ $reportColumns->where('IS_VISIBLE', 1)->count() }} Visible
                                    </span>
                                    <button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); addColumnForReport('{{ $reportCode }}')" style="margin-left: 10px;">
                                        ➕ Tambah
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="group-content" id="column-group-{{ $reportCode }}">
                            <table class="table group-table">
                                <thead>
                                    <tr>
                                        <th width="8%">ID</th>
                                        <th width="20%">Nama Kolom</th>
                                        <th width="20%">Label</th>
                                        <th width="10%">Width</th>
                                        <th width="10%">Align</th>
                                        <th width="12%">Tipe Data</th>
                                        <th width="8%">Visible</th>
                                        <th width="12%">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($reportColumns->sortBy('SORT_ORDER') as $column)
                                    <tr class="column-row" data-column-name="{{ strtolower($column->COLUMN_NAME) }}">
                                        <td><strong>{{ $column->ID }}</strong></td>
                                        <td><span class="filter-name">{{ $column->COLUMN_NAME }}</span></td>
                                        <td>{{ $column->COLUMN_LABEL }}</td>
                                        <td>{{ $column->WIDTH }}</td>
                                        <td><span class="badge badge-success">{{ $column->ALIGNMENT }}</span></td>
                                        <td><span class="filter-type-badge type-{{ strtolower($column->DATA_TYPE) }}">{{ $column->DATA_TYPE }}</span></td>
                                        <td>
                                            @if($column->IS_VISIBLE)
                                                <span class="badge badge-success">✓ Ya</span>
                                            @else
                                                <span class="badge badge-danger">✗ Tidak</span>
                                            @endif
                                        </td>
                                        <td>
                                            <button class="btn btn-secondary btn-sm" onclick="editColumn({{ $column->ID }})" style="margin-right: 5px;">
                                                ✏️
                                            </button>
                                            <button class="btn btn-danger btn-sm" onclick="deleteColumn({{ $column->ID }})">
                                                🗑️
                                            </button>
                                        </td>
                                    </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>
        </div>

        <!-- Report Groups Tab -->
        <div id="groups" class="tab-content">
            <div class="section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3>📁 Group Laporan</h3>
                    <button class="btn btn-primary" onclick="openGroupModal()">
                        ➕ Tambah Group Baru
                    </button>
                </div>

                <div class="search-box">
                    <input type="text" id="groupSearch" class="form-control" placeholder="Cari berdasarkan kode laporan atau field group..." onkeyup="filterGroups()">
                </div>

                <table class="table" id="groupsTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Kode Laporan</th>
                            <th>Group Field</th>
                            <th>Group Label</th>
                            <th>Opsi</th>
                            <th>Sort Order</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($reportGroups as $group)
                        <tr>
                            <td>{{ $group->ID }}</td>
                            <td><span class="report-code">{{ $group->KODEREPORT }}</span></td>
                            <td><strong>{{ $group->GROUP_FIELD }}</strong></td>
                            <td>{{ $group->GROUP_LABEL }}</td>
                            <td>
                                @if($group->SHOW_HEADER)<span class="badge badge-success">📄</span>@endif
                                @if($group->SHOW_FOOTER)<span class="badge badge-success">📋</span>@endif
                                @if($group->SHOW_SUM)<span class="badge badge-success">Σ</span>@endif
                                @if($group->PAGE_BREAK)<span class="badge badge-warning">📄</span>@endif
                            </td>
                            <td class="text-center">{{ $group->SORT_ORDER }}</td>
                            <td>
                                <button class="btn btn-secondary btn-sm" onclick="editGroup({{ $group->ID }})" style="margin-right: 5px;">
                                    ✏️ Edit
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteGroup({{ $group->ID }})">
                                    🗑️ Hapus
                                </button>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Reports Tab -->
        <div id="reports" class="tab-content">
            <div class="section">
                <h3>📋 Daftar Laporan</h3>
                <div class="reports-grid">
                    @foreach($reports as $report)
                    <div class="report-card">
                        <div class="report-code">{{ $report['code'] }}</div>
                        <h4>{{ $report['title'] }}</h4>
                        @if($report['subtitle'])
                            <p style="color: #666; font-size: 14px;">{{ $report['subtitle'] }}</p>
                        @endif
                        <div style="margin-top: 15px;">
                            <span class="badge badge-success">
                                {{ count(array_filter($filters, function($f) use ($report) { return $f->KODEREPORT == $report['code']; })) }} Filter
                            </span>
                        </div>
                        <button class="btn btn-primary" style="margin-top: 15px; width: 100%;" onclick="addFilterForReport('{{ $report['code'] }}')">
                            ➕ Tambah Filter
                        </button>
                    </div>
                    @endforeach
                </div>
            </div>
        </div>
    </div>

    <!-- Filter Modal -->
    <div id="filterModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="modalTitle">Tambah Filter Baru</h3>
                <span class="close" onclick="closeFilterModal()">&times;</span>
            </div>

            <div id="alertContainer"></div>

            <form id="filterForm">
                <input type="hidden" id="filterId" name="ID">

                <div class="form-group">
                    <label for="reportCode">Kode Laporan *</label>
                    <select id="reportCode" name="KODEREPORT" class="form-control" required>
                        <option value="">Pilih Laporan</option>
                        @foreach($reports as $report)
                        <option value="{{ $report['code'] }}">{{ $report['code'] }} - {{ $report['title'] }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="filterName">Nama Filter *</label>
                        <input type="text" id="filterName" name="FILTER_NAME" class="form-control" required
                               placeholder="e.g. search_perkiraan">
                    </div>
                    <div class="form-group">
                        <label for="filterLabel">Label Filter *</label>
                        <input type="text" id="filterLabel" name="FILTER_LABEL" class="form-control" required
                               placeholder="e.g. Cari Perkiraan">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="filterType">Tipe Filter *</label>
                        <select id="filterType" name="FILTER_TYPE" class="form-control" required onchange="toggleFilterOptions()">
                            <option value="">Pilih Tipe</option>
                            <option value="text">Text</option>
                            <option value="select">Select/Dropdown</option>
                            <option value="date">Date</option>
                            <option value="number">Number</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="sortOrder">Urutan Tampil *</label>
                        <input type="number" id="sortOrder" name="SORT_ORDER" class="form-control" required min="1" value="1">
                    </div>
                </div>

                <div id="filterOptionsGroup" class="form-group" style="display: none;">
                    <label for="filterOptions">Opsi Filter (untuk Select)</label>
                    <textarea id="filterOptions" name="FILTER_OPTIONS" class="form-control" rows="3"
                              placeholder="Format: value1|label1&#10;value2|label2&#10;..."></textarea>
                    <small style="color: #666;">Contoh untuk kelompok: 0|Aktiva, 1|Passiva, 2|Pendapatan</small>
                </div>

                <div class="form-group">
                    <label for="defaultValue">Nilai Default</label>
                    <input type="text" id="defaultValue" name="DEFAULT_VALUE" class="form-control"
                           placeholder="Nilai default (opsional)">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="isVisible" name="IS_VISIBLE" value="1" checked style="margin-right: 10px;">
                            Filter Terlihat
                        </label>
                    </div>
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="isRequired" name="IS_REQUIRED" value="1" style="margin-right: 10px;">
                            Filter Wajib Diisi
                        </label>
                    </div>
                </div>

                <div style="text-align: right; margin-top: 30px;">
                    <button type="button" class="btn btn-secondary" onclick="closeFilterModal()">Batal</button>
                    <button type="submit" class="btn btn-success" style="margin-left: 10px;">💾 Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Config Modal -->
    <div id="configModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="configModalTitle">Tambah Config Baru</h3>
                <span class="close" onclick="closeConfigModal()">&times;</span>
            </div>

            <div id="configAlertContainer"></div>

            <form id="configForm">
                <input type="hidden" id="configId" name="ID">

                <div class="form-group">
                    <label for="configReportCode">Kode Laporan *</label>
                    <select id="configReportCode" name="KODEREPORT" class="form-control" required>
                        <option value="">Pilih Laporan</option>
                        @foreach($reports as $report)
                        <option value="{{ $report['code'] }}">{{ $report['code'] }} - {{ $report['title'] }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="configType">Tipe Config *</label>
                        <select id="configType" name="CONFIG_TYPE" class="form-control" required>
                            <option value="">Pilih Tipe</option>
                            <option value="SHARED">SHARED</option>
                            <option value="DYNAMIC">DYNAMIC</option>
                            <option value="STATIC">STATIC</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="storedProc">Stored Procedure</label>
                        <input type="text" id="storedProc" name="STOREDPROC" class="form-control" placeholder="sp_ReportName">
                    </div>
                </div>

                <div class="form-group">
                    <label for="configJson">Config JSON *</label>
                    <textarea id="configJson" name="CONFIG_JSON" class="form-control" rows="6" required
                              placeholder='{"dataSource": "table_name", "orderBy": "field_name", "title": "Report Title"}'></textarea>
                </div>

                <div class="form-group">
                    <label style="display: flex; align-items: center;">
                        <input type="checkbox" id="configIsActive" name="IS_ACTIVE" value="1" checked style="margin-right: 10px;">
                        Config Aktif
                    </label>
                </div>

                <div style="text-align: right; margin-top: 30px;">
                    <button type="button" class="btn btn-secondary" onclick="closeConfigModal()">Batal</button>
                    <button type="submit" class="btn btn-success" style="margin-left: 10px;">💾 Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Header Modal -->
    <div id="headerModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="headerModalTitle">Tambah Header Baru</h3>
                <span class="close" onclick="closeHeaderModal()">&times;</span>
            </div>

            <div id="headerAlertContainer"></div>

            <form id="headerForm">
                <input type="hidden" id="headerId" name="ID">

                <div class="form-group">
                    <label for="headerReportCode">Kode Laporan *</label>
                    <select id="headerReportCode" name="KODEREPORT" class="form-control" required>
                        <option value="">Pilih Laporan</option>
                        @foreach($reports as $report)
                        <option value="{{ $report['code'] }}">{{ $report['code'] }} - {{ $report['title'] }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="headerTitle">Judul Laporan *</label>
                        <input type="text" id="headerTitle" name="TITLE" class="form-control" required placeholder="Laporan XYZ">
                    </div>
                    <div class="form-group">
                        <label for="headerSubtitle">Subjudul</label>
                        <input type="text" id="headerSubtitle" name="SUBTITLE" class="form-control" placeholder="DANA PENSIUN...">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="orientation">Orientasi *</label>
                        <select id="orientation" name="ORIENTATION" class="form-control" required>
                            <option value="">Pilih Orientasi</option>
                            <option value="PORTRAIT">PORTRAIT</option>
                            <option value="LANDSCAPE">LANDSCAPE</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="pageSize">Ukuran Halaman *</label>
                        <select id="pageSize" name="PAGE_SIZE" class="form-control" required>
                            <option value="">Pilih Ukuran</option>
                            <option value="A4">A4</option>
                            <option value="A3">A3</option>
                            <option value="LETTER">LETTER</option>
                            <option value="LEGAL">LEGAL</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="showDate" name="SHOW_DATE" value="1" checked style="margin-right: 10px;">
                            Tampilkan Tanggal
                        </label>
                    </div>
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="showParams" name="SHOW_PARAMS" value="1" style="margin-right: 10px;">
                            Tampilkan Parameter
                        </label>
                    </div>
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="showLogo" name="SHOW_LOGO" value="1" checked style="margin-right: 10px;">
                            Tampilkan Logo
                        </label>
                    </div>
                </div>

                <div style="text-align: right; margin-top: 30px;">
                    <button type="button" class="btn btn-secondary" onclick="closeHeaderModal()">Batal</button>
                    <button type="submit" class="btn btn-success" style="margin-left: 10px;">💾 Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Column Modal -->
    <div id="columnModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="columnModalTitle">Tambah Kolom Baru</h3>
                <span class="close" onclick="closeColumnModal()">&times;</span>
            </div>

            <div id="columnAlertContainer"></div>

            <form id="columnForm">
                <input type="hidden" id="columnId" name="ID">

                <div class="form-group">
                    <label for="columnReportCode">Kode Laporan *</label>
                    <select id="columnReportCode" name="KODEREPORT" class="form-control" required>
                        <option value="">Pilih Laporan</option>
                        @foreach($reports as $report)
                        <option value="{{ $report['code'] }}">{{ $report['code'] }} - {{ $report['title'] }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="columnName">Nama Kolom *</label>
                        <input type="text" id="columnName" name="COLUMN_NAME" class="form-control" required placeholder="field_name">
                    </div>
                    <div class="form-group">
                        <label for="columnLabel">Label Kolom *</label>
                        <input type="text" id="columnLabel" name="COLUMN_LABEL" class="form-control" required placeholder="Field Name">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="columnWidth">Width *</label>
                        <input type="number" id="columnWidth" name="WIDTH" class="form-control" required min="10" value="100">
                    </div>
                    <div class="form-group">
                        <label for="columnAlignment">Alignment *</label>
                        <select id="columnAlignment" name="ALIGNMENT" class="form-control" required>
                            <option value="">Pilih Alignment</option>
                            <option value="LEFT">LEFT</option>
                            <option value="CENTER">CENTER</option>
                            <option value="RIGHT">RIGHT</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="columnDataType">Tipe Data *</label>
                        <select id="columnDataType" name="DATA_TYPE" class="form-control" required>
                            <option value="">Pilih Tipe</option>
                            <option value="TEXT">TEXT</option>
                            <option value="NUMBER">NUMBER</option>
                            <option value="DATE">DATE</option>
                            <option value="DATETIME">DATETIME</option>
                            <option value="CURRENCY">CURRENCY</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="formatMask">Format Mask</label>
                        <input type="text" id="formatMask" name="FORMAT_MASK" class="form-control" placeholder="dd/MM/yyyy atau #,##0.00">
                    </div>
                    <div class="form-group">
                        <label for="columnSortOrder">Sort Order *</label>
                        <input type="number" id="columnSortOrder" name="SORT_ORDER" class="form-control" required min="1" value="1">
                    </div>
                </div>

                <div class="form-group">
                    <label style="display: flex; align-items: center;">
                        <input type="checkbox" id="columnIsVisible" name="IS_VISIBLE" value="1" checked style="margin-right: 10px;">
                        Kolom Terlihat
                    </label>
                </div>

                <div style="text-align: right; margin-top: 30px;">
                    <button type="button" class="btn btn-secondary" onclick="closeColumnModal()">Batal</button>
                    <button type="submit" class="btn btn-success" style="margin-left: 10px;">💾 Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Group Modal -->
    <div id="groupModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="groupModalTitle">Tambah Group Baru</h3>
                <span class="close" onclick="closeGroupModal()">&times;</span>
            </div>

            <div id="groupAlertContainer"></div>

            <form id="groupForm">
                <input type="hidden" id="groupId" name="ID">

                <div class="form-group">
                    <label for="groupReportCode">Kode Laporan *</label>
                    <select id="groupReportCode" name="KODEREPORT" class="form-control" required>
                        <option value="">Pilih Laporan</option>
                        @foreach($reports as $report)
                        <option value="{{ $report['code'] }}">{{ $report['code'] }} - {{ $report['title'] }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="groupField">Group Field *</label>
                        <input type="text" id="groupField" name="GROUP_FIELD" class="form-control" required placeholder="field_name">
                    </div>
                    <div class="form-group">
                        <label for="groupLabel">Group Label *</label>
                        <input type="text" id="groupLabel" name="GROUP_LABEL" class="form-control" required placeholder="Group Label">
                    </div>
                </div>

                <div class="form-group">
                    <label for="sumFields">Sum Fields</label>
                    <textarea id="sumFields" name="SUM_FIELDS" class="form-control" rows="3"
                              placeholder="field1,field2,field3 (fields untuk dijumlah)"></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="groupSortOrder">Sort Order *</label>
                        <input type="number" id="groupSortOrder" name="SORT_ORDER" class="form-control" required min="1" value="1">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="showHeader" name="SHOW_HEADER" value="1" checked style="margin-right: 10px;">
                            Tampilkan Header
                        </label>
                    </div>
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="showFooter" name="SHOW_FOOTER" value="1" style="margin-right: 10px;">
                            Tampilkan Footer
                        </label>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="showSum" name="SHOW_SUM" value="1" style="margin-right: 10px;">
                            Tampilkan Sum
                        </label>
                    </div>
                    <div class="form-group">
                        <label style="display: flex; align-items: center;">
                            <input type="checkbox" id="pageBreak" name="PAGE_BREAK" value="1" style="margin-right: 10px;">
                            Page Break
                        </label>
                    </div>
                </div>

                <div style="text-align: right; margin-top: 30px;">
                    <button type="button" class="btn btn-secondary" onclick="closeGroupModal()">Batal</button>
                    <button type="submit" class="btn btn-success" style="margin-left: 10px;">💾 Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // CSRF Token setup
        window.csrf = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

        // Tab switching
        function switchTab(tabName) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });

            // Remove active class from all tabs
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });

            // Show selected tab content
            document.getElementById(tabName).classList.add('active');

            // Add active class to clicked tab
            event.target.classList.add('active');

            // Load data for specific tabs
            if (tabName === 'overview') {
                loadOverviewData();
            }
        }

        // Modal functions
        function openFilterModal(reportCode = null) {
            document.getElementById('filterModal').style.display = 'block';
            document.getElementById('modalTitle').textContent = 'Tambah Filter Baru';
            document.getElementById('filterForm').reset();
            document.getElementById('filterId').value = '';

            if (reportCode) {
                document.getElementById('reportCode').value = reportCode;
            }

            clearAlert();
        }

        function closeFilterModal() {
            document.getElementById('filterModal').style.display = 'none';
        }

        function addFilterForReport(reportCode) {
            openFilterModal(reportCode);
        }

        // Toggle filter options field based on filter type
        function toggleFilterOptions() {
            const filterType = document.getElementById('filterType').value;
            const optionsGroup = document.getElementById('filterOptionsGroup');

            if (filterType === 'select') {
                optionsGroup.style.display = 'block';
            } else {
                optionsGroup.style.display = 'none';
            }
        }

        // Group toggle functionality
        function toggleGroup(reportCode) {
            const groupContent = document.getElementById(`group-${reportCode}`);
            const toggleIcon = document.getElementById(`icon-${reportCode}`);

            if (groupContent.classList.contains('collapsed')) {
                groupContent.classList.remove('collapsed');
                toggleIcon.classList.remove('collapsed');
                toggleIcon.textContent = '▼';
            } else {
                groupContent.classList.add('collapsed');
                toggleIcon.classList.add('collapsed');
                toggleIcon.textContent = '▶';
            }
        }

        // Filter groups search
        function filterGroups() {
            const searchTerm = document.getElementById('filterSearch').value.toLowerCase();
            const filterGroups = document.querySelectorAll('.filter-group');

            filterGroups.forEach(group => {
                const reportCode = group.dataset.reportCode.toLowerCase();
                const filterRows = group.querySelectorAll('.filter-row');
                let hasVisibleFilters = false;

                // Check if report code matches search term
                const reportMatches = reportCode.includes(searchTerm);

                // Check each filter in the group
                filterRows.forEach(row => {
                    const filterName = row.dataset.filterName;
                    const filterType = row.dataset.filterType;
                    const rowText = row.textContent.toLowerCase();

                    const matchesSearch = reportMatches ||
                                        filterName.includes(searchTerm) ||
                                        filterType.includes(searchTerm) ||
                                        rowText.includes(searchTerm);

                    if (matchesSearch) {
                        row.style.display = '';
                        hasVisibleFilters = true;
                    } else {
                        row.style.display = 'none';
                    }
                });

                // Show/hide the entire group based on whether it has visible filters
                if (hasVisibleFilters || searchTerm === '') {
                    group.style.display = '';
                    // Auto-expand groups that have matches
                    if (searchTerm !== '' && hasVisibleFilters) {
                        const groupContent = group.querySelector('.group-content');
                        const toggleIcon = group.querySelector('.toggle-icon');
                        if (groupContent.classList.contains('collapsed')) {
                            groupContent.classList.remove('collapsed');
                            toggleIcon.classList.remove('collapsed');
                            toggleIcon.textContent = '▼';
                        }
                    }
                } else {
                    group.style.display = 'none';
                }
            });
        }

        // Expand all groups
        function expandAllGroups() {
            const allGroups = document.querySelectorAll('.filter-group');
            allGroups.forEach(group => {
                const reportCode = group.dataset.reportCode;
                const groupContent = document.getElementById(`group-${reportCode}`);
                const toggleIcon = document.getElementById(`icon-${reportCode}`);

                groupContent.classList.remove('collapsed');
                toggleIcon.classList.remove('collapsed');
                toggleIcon.textContent = '▼';
            });
        }

        // Collapse all groups
        function collapseAllGroups() {
            const allGroups = document.querySelectorAll('.filter-group');
            allGroups.forEach(group => {
                const reportCode = group.dataset.reportCode;
                const groupContent = document.getElementById(`group-${reportCode}`);
                const toggleIcon = document.getElementById(`icon-${reportCode}`);

                groupContent.classList.add('collapsed');
                toggleIcon.classList.add('collapsed');
                toggleIcon.textContent = '▶';
            });
        }

        // Form submission
        document.getElementById('filterForm').addEventListener('submit', function(e) {
            e.preventDefault();
            saveFilter();
        });

        async function saveFilter() {
            const formData = new FormData(document.getElementById('filterForm'));
            const data = Object.fromEntries(formData.entries());

            // Convert checkboxes
            data.isVisible = document.getElementById('isVisible').checked;
            data.isRequired = document.getElementById('isRequired').checked;

            // Rename fields to match API expectations
            data.filterName = data.FILTER_NAME;
            data.fieldName = data.FILTER_NAME; // Use same as filterName for field mapping
            data.label = data.FILTER_LABEL;
            data.filterType = data.FILTER_TYPE.toLowerCase();
            data.sortOrder = parseInt(data.SORT_ORDER);
            data.optionsSource = data.FILTER_OPTIONS;
            data.defaultValue = data.DEFAULT_VALUE;

            const reportCode = data.KODEREPORT;
            const filterId = data.ID;

            try {
                let url, method;
                if (filterId) {
                    // Update existing filter
                    url = `/laporan-laporan/api/reports/${reportCode}/filters/${filterId}`;
                    method = 'PUT';
                } else {
                    // Create new filter
                    url = `/laporan-laporan/api/reports/${reportCode}/filters`;
                    method = 'POST';
                }

                const response = await fetch(url, {
                    method: method,
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': window.csrf
                    },
                    body: JSON.stringify(data)
                });

                const result = await response.json();

                if (result.success) {
                    showAlert('success', result.message);
                    setTimeout(() => {
                        location.reload();
                    }, 1500);
                } else {
                    showAlert('danger', result.message || 'Gagal menyimpan filter');
                }
            } catch (error) {
                console.error('Error saving filter:', error);
                showAlert('danger', 'Terjadi kesalahan saat menyimpan filter');
            }
        }

        function editFilter(filterId) {
            // Find the filter row in the grouped layout
            const filterRow = document.querySelector(`tr.filter-row:has(button[onclick="editFilter(${filterId})"])`);
            const cells = filterRow.querySelectorAll('td');

            // Extract data from table cells - adjusted for new layout
            const id = cells[0].textContent.trim();
            const filterName = cells[1].querySelector('.filter-name').textContent.trim();
            const filterLabel = cells[2].textContent.trim();
            const filterType = cells[3].querySelector('.filter-type-badge').textContent.trim();
            const isVisible = cells[4].textContent.includes('Ya');
            const isRequired = cells[5].textContent.includes('Required');
            const sortOrder = cells[6].textContent.trim();

            // Find the report code from the parent group
            const filterGroup = filterRow.closest('.filter-group');
            const reportCode = filterGroup.dataset.reportCode;

            // Fill form with filter data
            document.getElementById('filterId').value = id;
            document.getElementById('reportCode').value = reportCode;
            document.getElementById('filterName').value = filterName;
            document.getElementById('filterLabel').value = filterLabel;
            document.getElementById('filterType').value = filterType.toLowerCase();
            document.getElementById('sortOrder').value = sortOrder;
            document.getElementById('filterOptions').value = '';
            document.getElementById('defaultValue').value = '';
            document.getElementById('isVisible').checked = isVisible;
            document.getElementById('isRequired').checked = isRequired;

            // Update modal title
            document.getElementById('modalTitle').textContent = 'Edit Filter';

            // Show filter options if needed
            toggleFilterOptions();

            // Open modal
            document.getElementById('filterModal').style.display = 'block';
            clearAlert();
        }

        async function deleteFilter(filterId) {
            if (!confirm('Apakah Anda yakin ingin menghapus filter ini?')) {
                return;
            }

            // Find the report code for this filter from the grouped layout
            const filterRow = document.querySelector(`tr.filter-row:has(button[onclick="deleteFilter(${filterId})"])`);
            const filterGroup = filterRow.closest('.filter-group');
            const reportCode = filterGroup.dataset.reportCode;

            try {
                const response = await fetch(`/laporan-laporan/api/reports/${reportCode}/filters/${filterId}`, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-TOKEN': window.csrf
                    }
                });

                const result = await response.json();

                if (result.success) {
                    alert(result.message);
                    location.reload();
                } else {
                    alert(result.message || 'Gagal menghapus filter');
                }
            } catch (error) {
                console.error('Error deleting filter:', error);
                alert('Terjadi kesalahan saat menghapus filter');
            }
        }

        function showAlert(type, message) {
            const alertContainer = document.getElementById('alertContainer');
            const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';

            alertContainer.innerHTML = `
                <div class="alert ${alertClass}">
                    ${message}
                </div>
            `;
        }

        function clearAlert() {
            document.getElementById('alertContainer').innerHTML = '';
        }

        function loadOverviewData() {
            const filters = @json($filters);
            const reports = @json($reports);

            // Group filters by report
            const filtersByReport = {};
            filters.forEach(filter => {
                if (!filtersByReport[filter.KODEREPORT]) {
                    filtersByReport[filter.KODEREPORT] = [];
                }
                filtersByReport[filter.KODEREPORT].push(filter);
            });

            // Generate stats HTML
            let statsHtml = '';
            reports.forEach(report => {
                const reportFilters = filtersByReport[report.code] || [];
                const visibleFilters = reportFilters.filter(f => f.IS_VISIBLE == 1).length;

                statsHtml += `
                    <div style="background: white; padding: 15px; border-radius: 10px; margin-bottom: 10px; border-left: 4px solid #667eea;">
                        <h4>${report.code} - ${report.title}</h4>
                        <p>Total Filter: ${reportFilters.length} | Visible: ${visibleFilters}</p>
                    </div>
                `;
            });

            document.getElementById('filterStats').innerHTML = statsHtml;
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('filterModal');
            if (event.target === modal) {
                closeFilterModal();
            }
        }

        // Config Modal Functions
        function openConfigModal() {
            document.getElementById('configModal').style.display = 'block';
            document.getElementById('configModalTitle').textContent = 'Tambah Config Baru';
            document.getElementById('configForm').reset();
            document.getElementById('configId').value = '';
            clearConfigAlert();
        }

        function closeConfigModal() {
            document.getElementById('configModal').style.display = 'none';
        }

        function editConfig(configId) {
            // Implementation for editing config
            // This would fetch config data and populate the form
            openConfigModal();
            document.getElementById('configModalTitle').textContent = 'Edit Config';
            // TODO: Implement actual data loading
        }

        function deleteConfig(configId) {
            if (!confirm('Apakah Anda yakin ingin menghapus config ini?')) {
                return;
            }
            // TODO: Implement config deletion
        }

        function clearConfigAlert() {
            document.getElementById('configAlertContainer').innerHTML = '';
        }

        // Header Modal Functions
        function openHeaderModal() {
            document.getElementById('headerModal').style.display = 'block';
            document.getElementById('headerModalTitle').textContent = 'Tambah Header Baru';
            document.getElementById('headerForm').reset();
            document.getElementById('headerId').value = '';
            clearHeaderAlert();
        }

        function closeHeaderModal() {
            document.getElementById('headerModal').style.display = 'none';
        }

        function editHeader(headerId) {
            openHeaderModal();
            document.getElementById('headerModalTitle').textContent = 'Edit Header';
            // TODO: Implement actual data loading
        }

        function deleteHeader(headerId) {
            if (!confirm('Apakah Anda yakin ingin menghapus header ini?')) {
                return;
            }
            // TODO: Implement header deletion
        }

        function clearHeaderAlert() {
            document.getElementById('headerAlertContainer').innerHTML = '';
        }

        // Column Modal Functions
        function openColumnModal() {
            document.getElementById('columnModal').style.display = 'block';
            document.getElementById('columnModalTitle').textContent = 'Tambah Kolom Baru';
            document.getElementById('columnForm').reset();
            document.getElementById('columnId').value = '';
            clearColumnAlert();
        }

        function closeColumnModal() {
            document.getElementById('columnModal').style.display = 'none';
        }

        function addColumnForReport(reportCode) {
            openColumnModal();
            document.getElementById('columnReportCode').value = reportCode;
        }

        function editColumn(columnId) {
            openColumnModal();
            document.getElementById('columnModalTitle').textContent = 'Edit Kolom';
            // TODO: Implement actual data loading
        }

        function deleteColumn(columnId) {
            if (!confirm('Apakah Anda yakin ingin menghapus kolom ini?')) {
                return;
            }
            // TODO: Implement column deletion
        }

        function clearColumnAlert() {
            document.getElementById('columnAlertContainer').innerHTML = '';
        }

        // Column Group Toggle Functions
        function toggleColumnGroup(reportCode) {
            const groupContent = document.getElementById(`column-group-${reportCode}`);
            const toggleIcon = document.getElementById(`column-icon-${reportCode}`);

            if (groupContent.classList.contains('collapsed')) {
                groupContent.classList.remove('collapsed');
                toggleIcon.textContent = '▼';
            } else {
                groupContent.classList.add('collapsed');
                toggleIcon.textContent = '▶';
            }
        }

        function filterColumns() {
            const searchTerm = document.getElementById('columnSearch').value.toLowerCase();
            const columnGroups = document.querySelectorAll('[data-report-code]');

            columnGroups.forEach(group => {
                const reportCode = group.dataset.reportCode.toLowerCase();
                const columnRows = group.querySelectorAll('.column-row');
                let hasVisibleColumns = false;

                const reportMatches = reportCode.includes(searchTerm);

                columnRows.forEach(row => {
                    const columnName = row.dataset.columnName;
                    const rowText = row.textContent.toLowerCase();

                    const matchesSearch = reportMatches ||
                                        columnName.includes(searchTerm) ||
                                        rowText.includes(searchTerm);

                    if (matchesSearch) {
                        row.style.display = '';
                        hasVisibleColumns = true;
                    } else {
                        row.style.display = 'none';
                    }
                });

                if (hasVisibleColumns || searchTerm === '') {
                    group.style.display = '';
                } else {
                    group.style.display = 'none';
                }
            });
        }

        // Group Modal Functions
        function openGroupModal() {
            document.getElementById('groupModal').style.display = 'block';
            document.getElementById('groupModalTitle').textContent = 'Tambah Group Baru';
            document.getElementById('groupForm').reset();
            document.getElementById('groupId').value = '';
            clearGroupAlert();
        }

        function closeGroupModal() {
            document.getElementById('groupModal').style.display = 'none';
        }

        function editGroup(groupId) {
            openGroupModal();
            document.getElementById('groupModalTitle').textContent = 'Edit Group';
            // TODO: Implement actual data loading
        }

        function deleteGroup(groupId) {
            if (!confirm('Apakah Anda yakin ingin menghapus group ini?')) {
                return;
            }
            // TODO: Implement group deletion
        }

        function clearGroupAlert() {
            document.getElementById('groupAlertContainer').innerHTML = '';
        }

        function filterGroups() {
            const searchTerm = document.getElementById('groupSearch').value.toLowerCase();
            const tableRows = document.querySelectorAll('#groupsTable tbody tr');

            tableRows.forEach(row => {
                const rowText = row.textContent.toLowerCase();
                if (rowText.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        // Form submission handlers
        document.addEventListener('DOMContentLoaded', function() {
            // Config form submission
            const configForm = document.getElementById('configForm');
            if (configForm) {
                configForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    saveConfig();
                });
            }

            // Header form submission
            const headerForm = document.getElementById('headerForm');
            if (headerForm) {
                headerForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    saveHeader();
                });
            }

            // Column form submission
            const columnForm = document.getElementById('columnForm');
            if (columnForm) {
                columnForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    saveColumn();
                });
            }

            // Group form submission
            const groupForm = document.getElementById('groupForm');
            if (groupForm) {
                groupForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    saveGroup();
                });
            }

            loadOverviewData();
        });

        // Save functions (placeholders for now)
        async function saveConfig() {
            // TODO: Implement config saving
            alert('Config save functionality will be implemented');
        }

        async function saveHeader() {
            // TODO: Implement header saving
            alert('Header save functionality will be implemented');
        }

        async function saveColumn() {
            // TODO: Implement column saving
            alert('Column save functionality will be implemented');
        }

        async function saveGroup() {
            // TODO: Implement group saving
            alert('Group save functionality will be implemented');
        }

        // Enhanced modal close functionality
        window.onclick = function(event) {
            const filterModal = document.getElementById('filterModal');
            const configModal = document.getElementById('configModal');
            const headerModal = document.getElementById('headerModal');
            const columnModal = document.getElementById('columnModal');
            const groupModal = document.getElementById('groupModal');

            if (event.target === filterModal) {
                closeFilterModal();
            } else if (event.target === configModal) {
                closeConfigModal();
            } else if (event.target === headerModal) {
                closeHeaderModal();
            } else if (event.target === columnModal) {
                closeColumnModal();
            } else if (event.target === groupModal) {
                closeGroupModal();
            }
        }

    </script>
</body>
</html>