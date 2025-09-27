<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📊 Sistem Laporan DAPEN-KA</title>
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
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 40px;
            max-width: 800px;
            width: 90%;
        }

        .header {
            text-align: center;
            margin-bottom: 40px;
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

        .reports-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .report-card {
            background: #f8f9ff;
            border: 2px solid #e1e5f2;
            border-radius: 15px;
            padding: 25px;
            text-decoration: none;
            color: inherit;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .report-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            border-color: #667eea;
        }

        .report-code {
            background: #667eea;
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 15px;
        }

        .report-title {
            font-size: 1.3em;
            font-weight: bold;
            color: #333;
            margin-bottom: 8px;
        }

        .report-description {
            color: #666;
            font-size: 0.95em;
            line-height: 1.4;
        }

        .info-box {
            background: #e8f4fd;
            border: 1px solid #b3daff;
            border-radius: 10px;
            padding: 20px;
            margin-top: 30px;
        }

        .info-box h3 {
            color: #1976d2;
            margin-bottom: 10px;
        }

        .info-box p {
            color: #424242;
            line-height: 1.5;
        }

        .status-badge {
            display: inline-block;
            background: #4caf50;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Sistem Laporan DAPEN-KA</h1>
            <p>Pilih laporan yang ingin Anda lihat</p>
        </div>

        <div class="reports-grid">
            @foreach($reports as $report)
            <a href="/reports/{{ $report['code'] }}" class="report-card">
                <div class="report-code">{{ $report['code'] }}</div>
                <div class="report-title">{{ $report['title'] }}</div>
                <div class="report-description">{{ $report['description'] }}</div>
            </a>
            @endforeach
        </div>

        <div class="info-box">
            <h3>ℹ️ Informasi Sistem</h3>
            <p>
                Sistem laporan DAPEN-KA menggunakan teknologi hybrid dengan backend Laravel 9.0
                dan konfigurasi database-driven yang memungkinkan customization laporan secara dinamis.
            </p>
            <div class="status-badge">✅ Backend Active</div>
        </div>
    </div>
</body>
</html>