<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📋 {{ $title }} - DAPEN-KA</title>
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
            padding: 40px;
            max-width: 1000px;
            margin: 0 auto;
        }

        .header {
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }

        .header h1 {
            color: #333;
            font-size: 2.2em;
            margin-bottom: 5px;
        }

        .header .subtitle {
            color: #666;
            font-size: 1.1em;
        }

        .report-code-badge {
            background: #667eea;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 20px;
        }

        .form-section {
            background: #f8f9ff;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid #e1e5f2;
        }

        .form-section h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.3em;
        }

        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .form-group {
            flex: 1;
            min-width: 200px;
        }

        .form-group label {
            display: block;
            color: #555;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e5f2;
            border-radius: 10px;
            font-size: 1em;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
        }

        .columns-preview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }

        .column-card {
            background: white;
            border: 1px solid #e1e5f2;
            border-radius: 10px;
            padding: 15px;
        }

        .column-name {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }

        .column-details {
            font-size: 0.9em;
            color: #666;
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 25px;
            font-size: 1em;
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
            transform: translateY(-2px);
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

        .btn-success {
            background: #4caf50;
            color: white;
        }

        .btn-success:hover {
            background: #45a049;
        }

        .info-panel {
            background: #e8f4fd;
            border: 1px solid #b3daff;
            border-radius: 10px;
            padding: 20px;
            margin-top: 20px;
        }

        .info-panel h4 {
            color: #1976d2;
            margin-bottom: 10px;
        }

        .config-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .config-item {
            background: white;
            padding: 10px;
            border-radius: 8px;
            border: 1px solid #ddd;
        }

        .config-label {
            font-weight: 600;
            color: #333;
            font-size: 0.9em;
        }

        .config-value {
            color: #666;
            font-size: 0.85em;
            margin-top: 2px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="report-code-badge">{{ $reportCode }}</div>
            <h1>{{ $title }}</h1>
            <p class="subtitle">{{ $config['header']['SUBTITLE'] ?? 'Form Parameter Laporan' }}</p>
        </div>

        <form id="reportForm" method="POST" action="/reports/{{ $reportCode }}/generate">
            @csrf

            <div class="form-section">
                <h3>📅 Parameter Laporan</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="start_date">Tanggal Mulai</label>
                        <input type="date" id="start_date" name="start_date" value="{{ date('Y-m-01') }}" required>
                    </div>
                    <div class="form-group">
                        <label for="end_date">Tanggal Akhir</label>
                        <input type="date" id="end_date" name="end_date" value="{{ date('Y-m-t') }}" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="format">Format Output</label>
                        <select id="format" name="format" required>
                            <option value="html">📄 Tampilan Web (HTML)</option>
                            <option value="excel">📊 Excel (.xlsx)</option>
                            <option value="pdf">📋 PDF Document</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="limit">Batas Data</label>
                        <select id="limit" name="limit">
                            <option value="100">100 baris</option>
                            <option value="500" selected>500 baris</option>
                            <option value="1000">1000 baris</option>
                            <option value="all">Semua data</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="form-section">
                <h3>📊 Konfigurasi Kolom</h3>
                <p style="color: #666; margin-bottom: 20px;">
                    Laporan ini akan menampilkan {{ count($config['columns']) }} kolom data sesuai konfigurasi database.
                </p>

                <div class="columns-preview">
                    @foreach($config['columns'] as $column)
                    <div class="column-card">
                        <div class="column-name">{{ $column['COLUMN_LABEL'] }}</div>
                        <div class="column-details">
                            {{ $column['COLUMN_NAME'] }} | {{ $column['DATA_TYPE'] }} | Width: {{ $column['WIDTH'] }}px
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>

            <div class="info-panel">
                <h4>ℹ️ Informasi Konfigurasi</h4>
                <div class="config-grid">
                    <div class="config-item">
                        <div class="config-label">Orientasi</div>
                        <div class="config-value">{{ $config['header']['ORIENTATION'] ?? 'PORTRAIT' }}</div>
                    </div>
                    <div class="config-item">
                        <div class="config-label">Ukuran Halaman</div>
                        <div class="config-value">{{ $config['header']['PAGE_SIZE'] ?? 'A4' }}</div>
                    </div>
                    <div class="config-item">
                        <div class="config-label">Stored Procedure</div>
                        <div class="config-value">{{ $config['main']['STOREDPROC'] ?? 'N/A' }}</div>
                    </div>
                    <div class="config-item">
                        <div class="config-label">Total Kolom</div>
                        <div class="config-value">{{ count($config['columns']) }} kolom</div>
                    </div>
                </div>
            </div>

            <div class="action-buttons">
                <button type="submit" class="btn btn-primary" onclick="setAction('preview')">
                    👁️ Preview Laporan
                </button>
                <button type="submit" class="btn btn-success" onclick="setAction('generate')">
                    📊 Generate Laporan
                </button>
                <a href="/reports" class="btn btn-secondary">
                    ← Kembali ke Daftar
                </a>
            </div>
        </form>
    </div>

    <script>
        function setAction(action) {
            const form = document.getElementById('reportForm');
            if (action === 'preview') {
                form.action = '/reports/{{ $reportCode }}/preview';
            } else {
                form.action = '/reports/{{ $reportCode }}/generate';
            }
        }

        // Auto-set end date when start date changes
        document.getElementById('start_date').addEventListener('change', function() {
            const startDate = new Date(this.value);
            const endDate = new Date(startDate.getFullYear(), startDate.getMonth() + 1, 0);
            document.getElementById('end_date').value = endDate.toISOString().split('T')[0];
        });
    </script>
</body>
</html>