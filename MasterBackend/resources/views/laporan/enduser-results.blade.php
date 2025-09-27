<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title }} - DAPEN-KA</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            padding: 30px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e1e5f2;
        }

        .header h1 {
            color: #333;
            font-size: 1.8em;
            margin-bottom: 5px;
        }

        .header .subtitle {
            color: #666;
            font-size: 1em;
            margin-bottom: 10px;
        }

        .report-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #f8f9ff;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .meta-item {
            font-size: 0.9em;
            color: #666;
        }

        .meta-item strong {
            color: #333;
        }

        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 0.9em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5a6fd8;
        }

        .btn-success {
            background: #4caf50;
            color: white;
        }

        .btn-success:hover {
            background: #45a049;
        }

        .btn-secondary {
            background: #f8f9ff;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn-secondary:hover {
            background: #667eea;
            color: white;
        }

        .table-container {
            background: white;
            border-radius: 8px;
            border: 1px solid #e1e5f2;
            overflow: hidden;
            margin-bottom: 20px;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9em;
        }

        .table thead th {
            background: #667eea;
            color: white;
            padding: 12px 8px;
            text-align: left;
            font-weight: 600;
            border-right: 1px solid #5a6fd8;
        }

        .table thead th:last-child {
            border-right: none;
        }

        .table tbody tr {
            border-bottom: 1px solid #e1e5f2;
        }

        .table tbody tr:hover {
            background: #f8f9ff;
        }

        .table tbody td {
            padding: 10px 8px;
            border-right: 1px solid #e1e5f2;
            vertical-align: top;
        }

        .table tbody td:last-child {
            border-right: none;
        }

        .text-right {
            text-align: right;
        }

        .text-center {
            text-align: center;
        }

        .currency {
            font-family: 'Courier New', monospace;
            font-weight: 600;
        }

        .summary-row {
            background: #f0f0f0 !important;
            font-weight: bold;
        }

        .summary-row:hover {
            background: #e8e8e8 !important;
        }

        .no-data {
            text-align: center;
            padding: 40px;
            color: #666;
        }

        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }

            .table-container {
                overflow-x: auto;
            }

            .table {
                min-width: 600px;
            }

            .action-bar {
                flex-direction: column;
                align-items: stretch;
            }

            .report-meta {
                flex-direction: column;
                text-align: center;
            }
        }

        @media print {
            body {
                background: white;
                padding: 0;
            }

            .container {
                box-shadow: none;
                border-radius: 0;
                padding: 20px;
            }

            .action-bar {
                display: none;
            }

            .btn {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ $title }}</h1>
            @if($subtitle)
                <p class="subtitle">{{ $subtitle }}</p>
            @endif
        </div>

        <div class="report-meta">
            <div class="meta-item">
                <strong>Nama Laporan:</strong> {{ $config['header']['TITLE'] ?? $title }}
            </div>
            <div class="meta-item">
                <strong>Periode:</strong> {{ $parameters['periode'] ?? '' }}/{{ $parameters['tahun'] ?? '' }}
            </div>
            <div class="meta-item">
                <strong>Devisi:</strong> {{ $parameters['devisi'] ?? '' }}
            </div>
            <div class="meta-item">
                <strong>Generated:</strong> {{ $generatedAt }}
            </div>
            <div class="meta-item">
                <strong>Total Records:</strong> {{ number_format($recordCount) }}
            </div>
        </div>

        <div class="action-bar">
            <div>
                <a href="/laporan-laporan/laporan/{{ $reportCode }}" class="btn btn-secondary">
                    ← Parameter Baru
                </a>
            </div>
            <div>
                <button onclick="window.print()" class="btn btn-primary">
                    🖨️ Print
                </button>
                <form method="POST" action="/api/reports/{{ $reportCode }}/export" style="display: inline-block;">
                    @csrf
                    @foreach($parameters as $key => $value)
                        <input type="hidden" name="{{ $key }}" value="{{ $value }}">
                    @endforeach
                    <input type="hidden" name="format" value="pdf">
                    <button type="submit" class="btn btn-success">
                        📄 Export PDF
                    </button>
                </form>
            </div>
        </div>

        <div class="table-container">
            @if(count($reportData) > 0)
                <table class="table">
                    <thead>
                        <tr>
                            @foreach($columnDefinitions as $column)
                                <th style="width: {{ $column['WIDTH'] }}px;">
                                    {{ $column['COLUMN_LABEL'] }}
                                </th>
                            @endforeach
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($reportData as $row)
                            <tr @if(isset($row['TOTAL']) || isset($row['total'])) class="summary-row" @endif>
                                @foreach($columnDefinitions as $column)
                                    @php
                                        $columnName = $column['COLUMN_NAME'];
                                        // Handle both array and object data structures
                                        if (is_array($row) && isset($row[$columnName])) {
                                            // New dynamic report structure with value objects
                                            if (is_array($row[$columnName]) && isset($row[$columnName]['value'])) {
                                                $value = $row[$columnName]['value'];
                                                $dataType = strtoupper($row[$columnName]['dataType'] ?? $column['DATA_TYPE']);
                                                $alignment = $row[$columnName]['alignment'] ?? '';
                                            } else {
                                                $value = $row[$columnName];
                                                $dataType = strtoupper($column['DATA_TYPE']);
                                                $alignment = in_array($dataType, ['DECIMAL', 'NUMERIC', 'MONEY', 'FLOAT', 'INT', 'BIGINT']) ? 'text-right' : '';
                                            }
                                        } else {
                                            // Fallback for object structure
                                            $value = $row->$columnName ?? '';
                                            $dataType = strtoupper($column['DATA_TYPE']);
                                            $alignment = in_array($dataType, ['DECIMAL', 'NUMERIC', 'MONEY', 'FLOAT', 'INT', 'BIGINT']) ? 'text-right' : '';
                                        }

                                        // Convert alignment to CSS class
                                        $alignmentClass = '';
                                        if ($alignment === 'RIGHT' || $alignment === 'text-right') {
                                            $alignmentClass = 'text-right';
                                        } elseif ($alignment === 'CENTER') {
                                            $alignmentClass = 'text-center';
                                        }

                                        // Format currency values
                                        if (in_array($dataType, ['MONEY', 'DECIMAL', 'NUMERIC']) && is_numeric($value)) {
                                            $value = number_format($value, 2, '.', ',');
                                        }
                                    @endphp
                                    <td class="{{ $alignmentClass }} @if(in_array($dataType, ['MONEY', 'DECIMAL', 'NUMERIC'])) currency @endif">
                                        {{ $value }}
                                    </td>
                                @endforeach
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @else
                <div class="no-data">
                    <p>📊 Tidak ada data untuk parameter yang dipilih</p>
                    <a href="/laporan/{{ $reportCode }}" class="btn btn-primary" style="margin-top: 15px;">
                        Coba Parameter Lain
                    </a>
                </div>
            @endif
        </div>

        <div class="report-meta">
            <div class="meta-item">
                <strong>Info:</strong> Laporan dibuat secara otomatis dari database DAPEN-KA
            </div>
            <div class="meta-item">
                <strong>Status:</strong> ✅ Data Valid
            </div>
        </div>
    </div>

    <script>
        // Auto-scroll to table if data exists
        @if(count($reportData) > 0)
            document.querySelector('.table-container').scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        @endif

        // Handle export form submission
        document.querySelector('form[action*="/export"]')?.addEventListener('submit', function(e) {
            const btn = this.querySelector('button[type="submit"]');
            btn.disabled = true;
            btn.innerHTML = '⏳ Exporting...';

            setTimeout(() => {
                btn.disabled = false;
                btn.innerHTML = '📄 Export PDF';
            }, 3000);
        });
    </script>
</body>
</html>