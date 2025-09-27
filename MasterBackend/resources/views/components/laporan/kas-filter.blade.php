{{-- Kas Harian Filter Component (sesuai screenshot Delphi) --}}
<div class="kas-filter-panel" id="kasFilterPanel" style="display: none;">
    <div class="filter-header">
        <h4>Kas Harian</h4>
        <button class="close-filter" onclick="closeKasFilter()">×</button>
    </div>

    <div class="filter-form">
        <div class="form-group">
            <label>Divisi</label>
            <select id="kasFilterDivisi" class="form-control">
                <option value="01">01</option>
                <option value="02">02</option>
                <option value="03">03</option>
            </select>
        </div>

        <div class="form-group">
            <label>Perkiraan</label>
            <input type="text" id="kasFilterPerkiraan" class="form-control" value="1201010" placeholder="Kode Perkiraan">
        </div>

        <div class="form-group">
            <label>Periode</label>
            <div class="periode-group">
                <label class="periode-label">Awal</label>
                <input type="date" id="kasFilterAwal" class="form-control date-input" value="{{ date('Y-m-01') }}">

                <label class="periode-label">Akhir</label>
                <input type="date" id="kasFilterAkhir" class="form-control date-input" value="{{ date('Y-m-t') }}">
            </div>
        </div>

        <div class="form-buttons">
            <button class="btn btn-primary" onclick="generateKasReport()">Generate</button>
            <button class="btn btn-secondary" onclick="customizeKasReport()">Customize</button>
            <button class="btn btn-default" onclick="selectAllKas()">Semua</button>
        </div>
    </div>
</div>

<style>
.kas-filter-panel {
    position: fixed;
    left: 260px;
    bottom: 20px;
    width: 280px;
    background: #ecf0f1;
    border: 1px solid #bdc3c7;
    border-radius: 4px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    z-index: 1000;
}

.filter-header {
    background: #34495e;
    color: white;
    padding: 8px 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top-left-radius: 4px;
    border-top-right-radius: 4px;
}

.filter-header h4 {
    margin: 0;
    font-size: 14px;
    font-weight: bold;
}

.close-filter {
    background: none;
    border: none;
    color: white;
    font-size: 16px;
    cursor: pointer;
    padding: 0;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.filter-form {
    padding: 12px;
}

.form-group {
    margin-bottom: 12px;
}

.form-group label {
    display: block;
    font-size: 12px;
    font-weight: bold;
    color: #2c3e50;
    margin-bottom: 4px;
}

.form-control {
    width: 100%;
    padding: 4px 6px;
    border: 1px solid #bdc3c7;
    border-radius: 2px;
    font-size: 12px;
    background: white;
}

.periode-group {
    display: grid;
    grid-template-columns: auto 1fr;
    gap: 6px;
    align-items: center;
}

.periode-label {
    font-size: 11px !important;
    margin-bottom: 0 !important;
    text-align: right;
    color: #7f8c8d;
}

.date-input {
    font-size: 11px;
}

.form-buttons {
    display: flex;
    gap: 6px;
    margin-top: 16px;
}

.btn {
    padding: 6px 12px;
    border: 1px solid #bdc3c7;
    border-radius: 2px;
    font-size: 11px;
    cursor: pointer;
    flex: 1;
    text-align: center;
}

.btn-primary {
    background: #3498db;
    color: white;
    border-color: #3498db;
}

.btn-secondary {
    background: #95a5a6;
    color: white;
    border-color: #95a5a6;
}

.btn-default {
    background: #ecf0f1;
    color: #2c3e50;
    border-color: #bdc3c7;
}

.btn:hover {
    opacity: 0.9;
}
</style>

<script>
function showKasFilter() {
    const panel = document.getElementById('kasFilterPanel');
    if (panel) {
        panel.style.display = 'block';
    }
}

function closeKasFilter() {
    const panel = document.getElementById('kasFilterPanel');
    if (panel) {
        panel.style.display = 'none';
    }
}

function generateKasReport() {
    const divisi = document.getElementById('kasFilterDivisi').value;
    const perkiraan = document.getElementById('kasFilterPerkiraan').value;
    const awal = document.getElementById('kasFilterAwal').value;
    const akhir = document.getElementById('kasFilterAkhir').value;

    console.log('Generating Kas Report:', {divisi, perkiraan, awal, akhir});

    // Trigger the actual report loading
    if (window.loadKasHarianReport) {
        window.loadKasHarianReport({divisi, perkiraan, awal, akhir});
    }
}

function customizeKasReport() {
    alert('Customize feature akan dikembangkan');
}

function selectAllKas() {
    document.getElementById('kasFilterPerkiraan').value = '';
    alert('Semua perkiraan kas akan ditampilkan');
}
</script>