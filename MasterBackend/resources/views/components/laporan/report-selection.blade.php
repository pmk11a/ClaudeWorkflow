{{-- Laporan Dashboard Report Selection Component --}}
<div class="report-selection" id="reportSelection">
    <div class="report-placeholder" id="reportPlaceholder">
        <div class="report-icon">📊</div>
        <h3>Pilih laporan untuk melihat data</h3>
        <p>Gunakan tree navigasi di sebelah kiri untuk memilih laporan yang akan ditampilkan</p>
    </div>

    <div class="report-content" id="reportContent" style="display: none;">
        {{-- Kas Parameter Form - shown when Kas Harian is selected --}}
        <div class="kas-parameter-section" id="kasParameterSection" style="display: none;">
            @include('components.laporan.kas-parameter-form')
        </div>

        <div class="report-header" id="reportHeader">
            <div class="company-header">
                <h2>DANA PENSIUN KARYAWAN</h2>
                <h3 id="reportTitle">Daftar Perkiraan</h3>
                <div class="report-period" id="reportPeriod" style="display: none;">
                    Periode: <span id="periodText"></span>
                </div>
                <div class="report-details" id="reportDetails" style="display: none;">
                    <span id="perkiraanText"></span>
                    <span id="divisiText" style="float: right;"></span>
                </div>
            </div>
        </div>

        <div class="report-table-container">
            <table class="report-table" id="reportTable">
                <thead>
                    <tr>
                        <th>Perkiraan</th>
                        <th>Keterangan</th>
                        <th>Kelompok</th>
                        <th>Debet/Kredit</th>
                        <th>Tipe</th>
                        <th>Valas</th>
                    </tr>
                </thead>
                <tbody id="reportTableBody">
                    {{-- Data will be populated via JavaScript --}}
                </tbody>
            </table>
        </div>

        <div class="report-loading" id="reportLoading" style="display: none;">
            <div class="loading-spinner">⏳</div>
            <p>Memuat data laporan...</p>
        </div>

        <div class="report-error" id="reportError" style="display: none;">
            <div class="error-icon">❌</div>
            <p id="errorMessage">Terjadi kesalahan saat memuat data</p>
        </div>
    </div>
</div>