{{-- Laporan Dashboard Export Options Component --}}
<div class="export-section">
    <h4>Export Options</h4>
    <div class="export-buttons">
        <a href="#" class="export-btn pdf" onclick="exportReport('pdf')">
            📄 Export PDF
        </a>
        <a href="#" class="export-btn excel" onclick="exportReport('excel')">
            📊 Export Excel
        </a>
        <a href="#" class="export-btn csv" onclick="exportReport('csv')">
            📃 Export CSV
        </a>
        <a href="#" class="export-btn print" onclick="printReport()">
            🖨️ Print
        </a>
    </div>
</div>