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
            max-width: 800px;
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
        }

        .form-section {
            background: #f8f9ff;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid #e1e5f2;
        }

        .form-section h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.2em;
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
        .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e5f2;
            border-radius: 8px;
            font-size: 1em;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
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
            border-radius: 8px;
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

        .report-info {
            background: #e8f4fd;
            border: 1px solid #b3daff;
            border-radius: 8px;
            padding: 15px;
            margin-top: 20px;
            text-align: center;
        }

        .report-info p {
            color: #1976d2;
            margin: 0;
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

        <form method="POST" action="{{ route('laporan-laporan.laporan.enduser.generate', $reportCode) }}">
            @csrf

            <div class="form-section">
                <h3>📅 Parameter Laporan</h3>

                <div class="form-row">
                    <div class="form-group">
                        <label for="periode">Periode</label>
                        <input type="text" id="periode" name="periode"
                               value="{{ date('m') }}"
                               placeholder="01" required>
                    </div>
                    <div class="form-group">
                        <label for="tahun">Tahun</label>
                        <input type="text" id="tahun" name="tahun"
                               value="{{ date('Y') }}"
                               placeholder="2023" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="devisi">Devisi</label>
                        <input type="text" id="devisi" name="devisi"
                               value="01"
                               placeholder="01" required>
                    </div>
                </div>
            </div>

            {{-- Dynamic Filters Section --}}
            @if(isset($filters) && count($filters) > 0)
            <div class="form-section">
                <h3>🔍 Filter Laporan</h3>

                <div class="filter-row">
                    @foreach($filters as $filter)
                        <div class="form-group">
                            <label for="{{ $filter['filterName'] }}">{{ $filter['filterLabel'] ?? $filter['filterName'] }}</label>

                            @if($filter['filterType'] === 'select')
                                <select id="{{ $filter['filterName'] }}" name="{{ $filter['filterName'] }}"
                                        @if($filter['isRequired'] ?? false) required @endif>
                                    <option value="">Pilih {{ $filter['filterLabel'] ?? $filter['filterName'] }}</option>
                                    {{-- Options will be loaded via JavaScript if optionsSource exists --}}
                                </select>
                            @elseif($filter['filterType'] === 'text')
                                <input type="text" id="{{ $filter['filterName'] }}" name="{{ $filter['filterName'] }}"
                                       value="{{ $filter['defaultValue'] ?? '' }}"
                                       placeholder="{{ $filter['filterLabel'] ?? $filter['filterName'] }}"
                                       @if($filter['isRequired'] ?? false) required @endif>
                            @elseif($filter['filterType'] === 'date')
                                <input type="date" id="{{ $filter['filterName'] }}" name="{{ $filter['filterName'] }}"
                                       value="{{ $filter['defaultValue'] ?? '' }}"
                                       @if($filter['isRequired'] ?? false) required @endif>
                            @elseif($filter['filterType'] === 'number')
                                <input type="number" id="{{ $filter['filterName'] }}" name="{{ $filter['filterName'] }}"
                                       value="{{ $filter['defaultValue'] ?? '' }}"
                                       placeholder="{{ $filter['filterLabel'] ?? $filter['filterName'] }}"
                                       @if($filter['isRequired'] ?? false) required @endif>
                            @endif
                        </div>
                    @endforeach
                </div>
            </div>
            @endif

            <div class="action-buttons">
                <button type="submit" class="btn btn-primary">
                    📊 Lihat Laporan
                </button>
                <a href="/reports" class="btn btn-secondary">
                    ← Kembali
                </a>
            </div>
        </form>

        <div class="report-info">
            <p>💡 Masukkan parameter periode dan tahun untuk menampilkan laporan keuangan</p>
        </div>
    </div>
</body>
</html>