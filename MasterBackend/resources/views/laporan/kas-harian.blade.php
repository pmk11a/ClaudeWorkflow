@extends('layouts.laporan.minimal')

@section('title', 'Laporan Kas Harian')

@push('styles')
<style>
.laporan-kas-container {
    display: flex;
    height: calc(100vh - 120px);
    background: #f5f5f5;
}

.sidebar-panel {
    width: 280px;
    background: white;
    border-right: 1px solid #ddd;
    display: flex;
    flex-direction: column;
}

.sidebar-header {
    padding: 10px 15px;
    border-bottom: 1px solid #ddd;
    background: #f8f9fa;
    position: relative;
}

.sidebar-header h4 {
    margin: 0;
    font-size: 14px;
    color: #666;
}

.sidebar-close {
    position: absolute;
    right: 10px;
    top: 8px;
    background: none;
    border: none;
    font-weight: bold;
    cursor: pointer;
    padding: 2px 6px;
}

.report-tree {
    flex: 1;
    overflow-y: auto;
    padding: 10px;
}

.tree-node {
    margin: 2px 0;
}

.tree-parent {
    font-weight: bold;
    color: #333;
    cursor: pointer;
    padding: 5px;
    border-radius: 3px;
}

.tree-parent:hover {
    background: #f0f0f0;
}

.tree-parent.expanded {
    background: #e3f2fd;
}

.tree-children {
    margin-left: 20px;
    display: none;
}

.tree-children.show {
    display: block;
}

.tree-item {
    padding: 4px 8px;
    cursor: pointer;
    border-radius: 3px;
    font-size: 13px;
}

.tree-item:hover {
    background: #f0f8ff;
}

.tree-item.active {
    background: #007bff;
    color: white;
}

.main-panel {
    flex: 1;
    display: flex;
    flex-direction: column;
    background: white;
}

.parameter-section {
    padding: 20px;
    border-bottom: 1px solid #ddd;
    background: #f8f9fa;
}

.parameter-form {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    align-items: end;
}

.form-group {
    display: flex;
    flex-direction: column;
}

.form-group label {
    font-size: 12px;
    font-weight: bold;
    margin-bottom: 4px;
    color: #333;
}

.form-control {
    padding: 6px 8px;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 13px;
}

.date-input {
    max-width: 120px;
}

.btn-group {
    display: flex;
    gap: 8px;
}

.btn {
    padding: 8px 16px;
    border: 1px solid #ccc;
    border-radius: 3px;
    background: white;
    cursor: pointer;
    font-size: 13px;
}

.btn-primary {
    background: #007bff;
    color: white;
    border-color: #007bff;
}

.btn-secondary {
    background: #6c757d;
    color: white;
    border-color: #6c757d;
}

.report-preview {
    flex: 1;
    padding: 20px;
    overflow: auto;
}

.report-header {
    text-align: center;
    margin-bottom: 20px;
}

.report-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 5px;
}

.report-subtitle {
    font-size: 14px;
    color: #666;
}

.report-info {
    display: flex;
    justify-content: space-between;
    margin-bottom: 20px;
    font-size: 12px;
}

.report-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
    margin-bottom: 20px;
}

.report-table th,
.report-table td {
    border: 1px solid #ccc;
    padding: 4px 6px;
    text-align: left;
}

.report-table th {
    background: #f8f9fa;
    font-weight: bold;
    text-align: center;
}

.report-table .number {
    text-align: right;
}

.report-table .center {
    text-align: center;
}

.summary-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-top: 20px;
    font-size: 12px;
}

.summary-box {
    border: 1px solid #ccc;
    padding: 10px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    margin: 2px 0;
}

.summary-total {
    font-weight: bold;
    border-top: 1px solid #333;
    padding-top: 4px;
    margin-top: 4px;
}

.loading {
    text-align: center;
    padding: 40px;
    color: #666;
}
</style>
@endpush

@section('content')
<div class="laporan-kas-container">
    <!-- Sidebar Panel -->
    <div class="sidebar-panel">
        <div class="sidebar-header">
            <h4>Setting</h4>
            <button class="sidebar-close" onclick="toggleSidebar()">X</button>
        </div>

        <div class="report-tree">
            <div class="tree-node">
                <div class="tree-parent" onclick="toggleTreeNode(this)">
                    📊 Master Accounting
                </div>
                <div class="tree-children">
                    <div class="tree-item" data-report="101">Master Perkiraan</div>
                    <div class="tree-item" data-report="102">Master Divisi</div>
                </div>
            </div>

            <div class="tree-node">
                <div class="tree-parent expanded" onclick="toggleTreeNode(this)">
                    💰 Kas dan Bank
                </div>
                <div class="tree-children show">
                    <div class="tree-item active" data-report="20101">Kas Harian</div>
                    <div class="tree-item" data-report="20102">Bank Harian</div>
                    <div class="tree-item" data-report="20109">Laporan Arus Kas</div>
                </div>
            </div>

            <div class="tree-node">
                <div class="tree-parent" onclick="toggleTreeNode(this)">
                    📊 General Ledger
                </div>
                <div class="tree-children">
                    <div class="tree-item" data-report="301">Jurnal Umum</div>
                    <div class="tree-item" data-report="302">Buku Besar</div>
                </div>
            </div>

            <div class="tree-node">
                <div class="tree-parent" onclick="toggleTreeNode(this)">
                    📈 Laporan Keuangan Bulanan
                </div>
                <div class="tree-children">
                    <div class="tree-item" data-report="401">Neraca</div>
                    <div class="tree-item" data-report="402">Laba Rugi</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Panel -->
    <div class="main-panel">
        <!-- Parameter Section -->
        <div class="parameter-section">
            <form id="reportForm" class="parameter-form">
                <input type="hidden" id="reportCode" value="20101">

                <div class="form-group">
                    <label>Divisi</label>
                    <select id="divisi" class="form-control">
                        <option value="01">01 - Kantor Pusat</option>
                        <option value="02">02 - Cabang Jakarta</option>
                        <option value="03">03 - Cabang Surabaya</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Perkiraan</label>
                    <input type="text" id="perkiraan" class="form-control" value="1201010" placeholder="Kode Perkiraan">
                </div>

                <div class="form-group">
                    <label>Periode Awal</label>
                    <input type="date" id="periodeAwal" class="form-control date-input" value="{{ date('Y-m-01') }}">
                </div>

                <div class="form-group">
                    <label>Periode Akhir</label>
                    <input type="date" id="periodeAkhir" class="form-control date-input" value="{{ date('Y-m-t') }}">
                </div>

                <div class="form-group">
                    <label>Jenis Rupiah</label>
                    <select id="jenisRupiah" class="form-control">
                        <option value="1">Rupiah</option>
                        <option value="2">Valas</option>
                    </select>
                </div>

                <div class="form-group">
                    <div class="btn-group">
                        <button type="button" class="btn btn-primary" onclick="generateReport()">Preview</button>
                        <button type="button" class="btn btn-secondary" onclick="customizeReport()">Customize</button>
                        <button type="button" class="btn" onclick="selectAll()">Semua</button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Report Preview -->
        <div class="report-preview">
            <div id="reportContent">
                <div class="loading">
                    Klik Preview untuk menampilkan laporan kas harian
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
// Global variables
let currentReportCode = '20101';

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    // Set initial report
    updateActiveReport('20101');

    // Auto-generate report if parameters are set
    if (hasValidParameters()) {
        generateReport();
    }
});

// Tree navigation
function toggleTreeNode(element) {
    const children = element.nextElementSibling;
    const isExpanded = element.classList.contains('expanded');

    if (isExpanded) {
        element.classList.remove('expanded');
        children.classList.remove('show');
    } else {
        element.classList.add('expanded');
        children.classList.add('show');
    }
}

// Report selection
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('tree-item')) {
        const reportCode = e.target.dataset.report;
        selectReport(reportCode, e.target);
    }
});

function selectReport(reportCode, element) {
    // Update active state
    document.querySelectorAll('.tree-item').forEach(item => {
        item.classList.remove('active');
    });
    element.classList.add('active');

    // Update form
    document.getElementById('reportCode').value = reportCode;
    currentReportCode = reportCode;

    // Update parameters based on report
    updateParametersForReport(reportCode);

    // Clear previous report
    document.getElementById('reportContent').innerHTML = '<div class="loading">Klik Preview untuk menampilkan laporan</div>';
}

function updateParametersForReport(reportCode) {
    const perkiraanField = document.getElementById('perkiraan');

    switch(reportCode) {
        case '20101': // Kas Harian
            perkiraanField.value = '1201010';
            perkiraanField.placeholder = 'Kode Kas';
            break;
        case '20102': // Bank Harian
            perkiraanField.value = '1201020';
            perkiraanField.placeholder = 'Kode Bank';
            break;
        case '20109': // Arus Kas
            perkiraanField.value = '';
            perkiraanField.placeholder = 'Semua Kas';
            break;
        default:
            perkiraanField.value = '';
            perkiraanField.placeholder = 'Kode Perkiraan';
    }
}

function updateActiveReport(reportCode) {
    const reportItem = document.querySelector(`[data-report="${reportCode}"]`);
    if (reportItem) {
        selectReport(reportCode, reportItem);
    }
}

// Form validation
function hasValidParameters() {
    const divisi = document.getElementById('divisi').value;
    const periodeAwal = document.getElementById('periodeAwal').value;
    const periodeAkhir = document.getElementById('periodeAkhir').value;

    return divisi && periodeAwal && periodeAkhir;
}

// Report generation
async function generateReport() {
    if (!hasValidParameters()) {
        alert('Mohon lengkapi parameter laporan');
        return;
    }

    const reportContent = document.getElementById('reportContent');
    reportContent.innerHTML = '<div class="loading">Generating report...</div>';

    const formData = {
        reportCode: currentReportCode,
        divisi: document.getElementById('divisi').value,
        perkiraan: document.getElementById('perkiraan').value,
        periodeAwal: document.getElementById('periodeAwal').value,
        periodeAkhir: document.getElementById('periodeAkhir').value,
        jenisRupiah: document.getElementById('jenisRupiah').value
    };

    try {
        const response = await fetch('/laporan-laporan/api/reports/' + currentReportCode, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify(formData)
        });

        const result = await response.json();

        if (result.success) {
            renderReport(result.data, formData);
        } else {
            reportContent.innerHTML = `<div class="loading">Error: ${result.message}</div>`;
        }
    } catch (error) {
        console.error('Error generating report:', error);
        reportContent.innerHTML = '<div class="loading">Terjadi kesalahan saat generate laporan</div>';
    }
}

function renderReport(data, params) {
    const reportContent = document.getElementById('reportContent');

    const html = `
        <div class="report-header">
            <div class="report-title">DANA PENSIUN KARYAWAN</div>
            <div class="report-title">LAPORAN KAS</div>
            <div class="report-subtitle">Periode: ${formatDate(params.periodeAwal)} s/d ${formatDate(params.periodeAkhir)}</div>
        </div>

        <div class="report-info">
            <div>Perkiraan: ${params.perkiraan} (Kas)</div>
            <div>Divisi: ${params.divisi}</div>
        </div>

        <table class="report-table">
            <thead>
                <tr>
                    <th rowspan="2">Tgl.</th>
                    <th rowspan="2">No.Bukti</th>
                    <th rowspan="2">URAIAN</th>
                    <th rowspan="2">Perk.</th>
                    <th colspan="2">Penerimaan</th>
                    <th colspan="2">Pengeluaran</th>
                </tr>
                <tr>
                    <th>TUNAI</th>
                    <th>CH / GB</th>
                    <th>TUNAI</th>
                    <th>CH / GB</th>
                </tr>
            </thead>
            <tbody>
                ${renderReportRows(data.transactions || [])}
            </tbody>
        </table>

        <div class="summary-section">
            <div class="summary-box">
                <div class="summary-row">
                    <span>Uang Tunai</span>
                    <span>Rp. ${formatNumber(data.summary?.uangTunai || 0)}</span>
                </div>
                <div class="summary-row">
                    <span>CH/GB</span>
                    <span>Rp. ${formatNumber(data.summary?.chGb || 0)}</span>
                </div>
                <div class="summary-row">
                    <span>CH/GB Tolakan</span>
                    <span>Rp. ${formatNumber(data.summary?.chGbTolakan || 0)}</span>
                </div>
                <div class="summary-row">
                    <span>Bon Sementara</span>
                    <span>Rp. ${formatNumber(data.summary?.bonSementara || 0)}</span>
                </div>
                <div class="summary-row summary-total">
                    <span>Sisa Keuangan</span>
                    <span>Rp. ${formatNumber(data.summary?.sisaKeuangan || 0)}</span>
                </div>
            </div>

            <div class="summary-box">
                <div class="summary-row">
                    <span>Sub. Jumlah / Dipindahkan</span>
                    <span>${formatNumber(data.summary?.subJumlah || 0)}</span>
                </div>
                <div class="summary-row">
                    <span>Jumlah</span>
                    <span>${formatNumber(data.summary?.jumlah || 0)}</span>
                </div>
                <div class="summary-row">
                    <span>Saldo Awal</span>
                    <span>${formatNumber(data.summary?.saldoAwal || 0)}</span>
                </div>
                <div class="summary-row summary-total">
                    <span>Saldo Akhir</span>
                    <span>${formatNumber(data.summary?.saldoAkhir || 0)}</span>
                </div>
            </div>
        </div>
    `;

    reportContent.innerHTML = html;
}

function renderReportRows(transactions) {
    if (!transactions.length) {
        return '<tr><td colspan="8" class="center">Tidak ada data transaksi</td></tr>';
    }

    return transactions.map(transaction => `
        <tr>
            <td class="center">${formatDateShort(transaction.tanggal)}</td>
            <td class="center">${transaction.noBukti || ''}</td>
            <td>${transaction.uraian || ''}</td>
            <td class="center">${transaction.perkiraan || ''}</td>
            <td class="number">${transaction.penerimaanTunai ? formatNumber(transaction.penerimaanTunai) : ''}</td>
            <td class="number">${transaction.penerimaanChGb ? formatNumber(transaction.penerimaanChGb) : ''}</td>
            <td class="number">${transaction.pengeluaranTunai ? formatNumber(transaction.pengeluaranTunai) : ''}</td>
            <td class="number">${transaction.pengeluaranChGb ? formatNumber(transaction.pengeluaranChGb) : ''}</td>
        </tr>
    `).join('');
}

// Utility functions
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
}

function formatDateShort(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', {
        day: '2-digit',
        month: '2-digit'
    });
}

function formatNumber(number) {
    return new Intl.NumberFormat('id-ID', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }).format(number);
}

// Sidebar toggle
function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar-panel');
    const main = document.querySelector('.main-panel');

    if (sidebar.style.display === 'none') {
        sidebar.style.display = 'flex';
        main.style.marginLeft = '0';
    } else {
        sidebar.style.display = 'none';
        main.style.marginLeft = '0';
        main.style.width = '100%';
    }
}

// Additional functions
function customizeReport() {
    alert('Customize feature akan dikembangkan');
}

function selectAll() {
    document.getElementById('perkiraan').value = '';
    alert('Semua perkiraan kas akan ditampilkan');
}
</script>
@endpush