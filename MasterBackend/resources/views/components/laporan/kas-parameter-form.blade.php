{{-- Kas Harian Parameter Form Component (sesuai screenshot) --}}
<div class="kas-parameter-form" id="kasParameterForm">
    <div class="parameter-row">
        <div class="parameter-group">
            <label for="divisi">Divisi</label>
            <select id="divisi" name="divisi" class="form-control">
                <option value="01">01 - Kantor Pusat</option>
                <option value="02">02 - Kantor Cabang</option>
                <option value="03">03 - Kantor Wilayah</option>
            </select>
        </div>

        <div class="parameter-group">
            <label for="perkiraan">Perkiraan</label>
            <input type="text" id="perkiraan" name="perkiraan" class="form-control" value="1201010" placeholder="Kode Perkiraan">
        </div>

        <div class="parameter-group">
            <label for="periodeAwal">Periode Awal</label>
            <input type="date" id="periodeAwal" name="periodeAwal" class="form-control" value="2025-07-01">
        </div>

        <div class="parameter-group">
            <label for="periodeAkhir">Periode Akhir</label>
            <input type="date" id="periodeAkhir" name="periodeAkhir" class="form-control" value="2025-07-31">
        </div>

        <div class="parameter-group">
            <label for="jenisRupiah">Jenis Rupiah</label>
            <select id="jenisRupiah" name="jenisRupiah" class="form-control">
                <option value="Rupiah">Rupiah</option>
                <option value="Dollar">Dollar</option>
                <option value="Euro">Euro</option>
            </select>
        </div>
    </div>

    <div class="parameter-buttons">
        <button type="button" id="previewButton" class="btn btn-primary">Preview</button>
        <button type="button" class="btn btn-secondary" onclick="customizeKasReport()">Customize</button>
        <button type="button" class="btn btn-default" onclick="resetKasFilters()">Semua</button>
    </div>
</div>

<style>
.kas-parameter-form {
    background: white;
    padding: 15px;
    border-radius: 6px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 20px;
    position: relative;
    z-index: 10;
}

.parameter-row {
    display: flex;
    gap: 15px;
    align-items: end;
    flex-wrap: wrap;
    margin-bottom: 15px;
}

.parameter-group {
    display: flex;
    flex-direction: column;
    min-width: 150px;
}

.parameter-group label {
    font-size: 12px;
    font-weight: 500;
    color: #2c3e50;
    margin-bottom: 4px;
}

.parameter-group .form-control {
    padding: 6px 8px;
    border: 1px solid #bdc3c7;
    border-radius: 3px;
    font-size: 12px;
    background: white;
}

.parameter-buttons {
    display: flex;
    gap: 8px;
    position: relative;
    z-index: 15;
}

.btn {
    padding: 8px 16px;
    border: 1px solid #bdc3c7;
    border-radius: 3px;
    font-size: 12px;
    cursor: pointer;
    text-align: center;
    min-width: 80px;
    position: relative;
    z-index: 20;
    pointer-events: auto;
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

.btn-default {
    background: #f8f9fa;
    color: #495057;
    border-color: #dee2e6;
}

.btn:hover {
    opacity: 0.9;
}

@media (max-width: 768px) {
    .parameter-row {
        flex-direction: column;
        align-items: stretch;
    }

    .parameter-group {
        min-width: auto;
    }
}
</style>

<script>
function generateKasReport() {
    const params = {
        divisi: document.getElementById('divisi').value,
        perkiraan: document.getElementById('perkiraan').value,
        periodeAwal: document.getElementById('periodeAwal').value,
        periodeAkhir: document.getElementById('periodeAkhir').value,
        jenisRupiah: document.getElementById('jenisRupiah').value
    };

    console.log('Generating Kas Report with params:', params);

    // Show loading state
    if (window.showReportLoading) {
        window.showReportLoading();
    }

    // Load kas report dengan parameter
    loadKasHarianWithParams(params);
}

function loadKasHarianWithParams(params) {
    const queryParams = new URLSearchParams(params).toString();

    fetch(`/laporan-laporan/api/reports/020101?${queryParams}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                console.log('Kas Harian API response received:', data);

                // Use global updateKasReportDisplay from dashboard.js
                if (window.updateKasReportDisplay) {
                    window.updateKasReportDisplay(data, params);
                } else {
                    console.error('updateKasReportDisplay function not found in window scope');
                }

                if (window.showReportTable) {
                    window.showReportTable();
                } else {
                    console.error('showReportTable function not found in window scope');
                }
            } else {
                console.error('Failed to load kas report:', data.error);
                if (window.showReportError) {
                    window.showReportError(data.error || 'Failed to load kas report');
                }
            }
        })
        .catch(error => {
            console.error('Error loading kas report:', error);
            if (window.showReportError) {
                window.showReportError('Network error: ' + error.message);
            }
        });
}

// Note: updateKasReportDisplay, getKasColumns, and formatDate functions
// are already available in dashboard.js - no need to duplicate here

function customizeKasReport() {
    alert('Customize feature akan dikembangkan');
}

function resetKasFilters() {
    document.getElementById('divisi').value = '01';
    document.getElementById('perkiraan').value = '1201010';
    document.getElementById('periodeAwal').value = '{{ date("Y-m-01") }}';
    document.getElementById('periodeAkhir').value = '{{ date("Y-m-t") }}';
    document.getElementById('jenisRupiah').value = 'Rupiah';
}

// Robust event listener for real user clicks
document.addEventListener('DOMContentLoaded', function() {
    // Wait a bit for all components to load
    setTimeout(function() {
        const previewButton = document.getElementById('previewButton');
        if (previewButton) {
            // Force button to be clickable
            previewButton.style.position = 'relative';
            previewButton.style.zIndex = '9999';
            previewButton.style.pointerEvents = 'auto';
            previewButton.style.display = 'inline-block';

            // Remove any existing listeners
            previewButton.removeEventListener('click', generateKasReport);

            // Add robust event listener
            previewButton.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();

                console.log('✅ Preview button REAL CLICK detected');
                console.log('Button element:', previewButton);
                console.log('Event:', e);

                // Call the function
                if (typeof generateKasReport === 'function') {
                    generateKasReport();
                } else {
                    console.error('generateKasReport function not found!');
                }
            }, true); // Use capture phase

            console.log('✅ Preview button event listener attached for REAL USER');
            console.log('Button element:', previewButton);
        } else {
            console.error('❌ Preview button not found!');
        }
    }, 500); // Wait 500ms for DOM to be fully ready
});
</script>