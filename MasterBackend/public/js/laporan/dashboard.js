/* DAPEN ERP - Laporan Dashboard Scripts */
/* Extracted from erp-dashboard.blade.php for clean code architecture */

let selectedReport = null;
let reportColumns = []; // Store dynamic column configuration

// Auto-expand submenu when page loads
document.addEventListener('DOMContentLoaded', function() {
    console.log('Page loaded, auto-expanding submenus...');

    // Force expand all submenus to show TreeView like Delphi
    setTimeout(() => {
        // Auto-expand Accounting submenu
        const accountingSubmenu = document.getElementById('submenu-020');
        if (accountingSubmenu) {
            accountingSubmenu.classList.add('active');
            accountingSubmenu.style.display = 'block';
            accountingSubmenu.style.visibility = 'visible';
            const accountingCategory = accountingSubmenu.previousElementSibling;
            if (accountingCategory) {
                accountingCategory.classList.add('active');
            }
            console.log('Auto-expanded Accounting submenu');
        }

        // Auto-expand Kas dan Bank submenu
        const kasSubmenu = document.getElementById('submenu-0201');
        if (kasSubmenu) {
            kasSubmenu.classList.add('active');
            kasSubmenu.style.display = 'block';
            kasSubmenu.style.visibility = 'visible';
            kasSubmenu.style.height = 'auto';
            kasSubmenu.style.overflow = 'visible';
            const kasCategory = kasSubmenu.previousElementSibling;
            if (kasCategory) {
                kasCategory.classList.add('active');
            }
            console.log('Auto-expanded Kas dan Bank submenu');

            // Show all kas submenu items
            const kasItems = kasSubmenu.querySelectorAll('.submenu-item');
            kasItems.forEach(item => {
                item.style.display = 'block';
                item.style.visibility = 'visible';
                console.log('Showing kas item:', item.textContent.trim());
            });
        }

        // Force expand all other submenus to make TreeView complete
        const allSubmenus = document.querySelectorAll('.submenu');
        allSubmenus.forEach(submenu => {
            submenu.classList.add('active');
            submenu.style.display = 'block';
            submenu.style.visibility = 'visible';
        });

        console.log('All submenus force-expanded like Delphi TreeView');
    }, 100);

    console.log('Initial check: Filters hidden - report already loaded');
});

function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');

    sidebar.classList.toggle('collapsed');
    mainContent.classList.toggle('expanded');
}

function toggleSubmenu(categoryKey) {
    const submenu = document.getElementById('submenu-' + categoryKey);
    const category = submenu.previousElementSibling;

    // Close all other submenus
    document.querySelectorAll('.submenu').forEach(menu => {
        if (menu.id !== 'submenu-' + categoryKey) {
            menu.classList.remove('active');
            menu.previousElementSibling.classList.remove('active');
        }
    });

    // Toggle current submenu
    submenu.classList.toggle('active');
    category.classList.toggle('active');
}

function selectReport(reportCode, reportTitle) {
    selectedReport = reportCode;

    // Update report title
    const reportTitleElement = document.getElementById('reportTitle');
    if (reportTitleElement) {
        reportTitleElement.textContent = reportTitle;
    }

    // Show report content
    showReportContent();

    // Handle specific reports
    if (reportTitle === 'Kas Harian' || reportCode === '020101') {
        showKasParameterForm();
    } else if (reportCode === '101' && reportTitle === 'Daftar Perkiraan') {
        hideKasParameterForm();
        clearReportHeader();
        showReportLoading();
        loadDaftarPerkiraan();
    } else {
        hideKasParameterForm();
        clearReportHeader();
        showReportLoading();
        // Try to load via universal report system
        loadUniversalReport(reportCode, reportTitle);
    }

    // Highlight selected item
    document.querySelectorAll('.submenu-item').forEach(item => {
        item.classList.remove('active');
    });
    if (event && event.target) {
        event.target.classList.add('active');
    }
}

function showKasParameterForm() {
    const kasSection = document.getElementById('kasParameterSection');
    const reportHeader = document.getElementById('reportHeader');
    const reportTable = document.getElementById('reportTable');
    const reportLoading = document.getElementById('reportLoading');
    const reportError = document.getElementById('reportError');

    // Show parameter form
    if (kasSection) kasSection.style.display = 'block';

    // Hide other elements
    if (reportTable) reportTable.style.display = 'none';
    if (reportLoading) reportLoading.style.display = 'none';
    if (reportError) reportError.style.display = 'none';

    // Update header for kas report
    if (reportHeader) {
        const periodDiv = document.getElementById('reportPeriod');
        const detailsDiv = document.getElementById('reportDetails');
        if (periodDiv) periodDiv.style.display = 'none';
        if (detailsDiv) detailsDiv.style.display = 'none';
    }

    console.log('Kas parameter form displayed');
}

function hideKasParameterForm() {
    const kasSection = document.getElementById('kasParameterSection');
    if (kasSection) kasSection.style.display = 'none';
}

function clearReportHeader() {
    // Clear period and details display for reports without filters
    const periodDiv = document.getElementById('reportPeriod');
    const detailsDiv = document.getElementById('reportDetails');

    if (periodDiv) periodDiv.style.display = 'none';
    if (detailsDiv) detailsDiv.style.display = 'none';

    // Reset report title to generic
    const reportHeader = document.querySelector('.report-header .company-header');
    if (reportHeader) {
        const h2 = reportHeader.querySelector('h2');
        const h3 = reportHeader.querySelector('h3');
        if (h2) h2.textContent = 'DANA PENSIUN KARYAWAN';
        if (h3) h3.textContent = 'SISTEM LAPORAN';
    }
}

function showReportPlaceholder() {
    const placeholder = document.getElementById('reportPlaceholder');
    const content = document.getElementById('reportContent');

    if (placeholder) placeholder.style.display = 'flex';
    if (content) content.style.display = 'none';
}

function showReportContent() {
    const placeholder = document.getElementById('reportPlaceholder');
    const content = document.getElementById('reportContent');

    if (placeholder) placeholder.style.display = 'none';
    if (content) content.style.display = 'block';
}

function showReportLoading() {
    showReportContent();
    const loading = document.getElementById('reportLoading');
    const table = document.getElementById('reportTable');
    const error = document.getElementById('reportError');

    if (loading) loading.style.display = 'block';
    if (table) table.style.display = 'none';
    if (error) error.style.display = 'none';
}

function showReportTable() {
    const loading = document.getElementById('reportLoading');
    const table = document.getElementById('reportTable');
    const error = document.getElementById('reportError');

    if (loading) loading.style.display = 'none';
    if (table) table.style.display = 'table';
    if (error) error.style.display = 'none';
}

function showReportError(message) {
    const loading = document.getElementById('reportLoading');
    const table = document.getElementById('reportTable');
    const error = document.getElementById('reportError');
    const errorMessage = document.getElementById('errorMessage');

    if (loading) loading.style.display = 'none';
    if (table) table.style.display = 'none';
    if (error) error.style.display = 'block';
    if (errorMessage) errorMessage.textContent = message;
}

function loadDaftarPerkiraan() {
    fetch('/laporan-laporan/api/daftar-perkiraan')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Store column configuration globally
                reportColumns = data.columns || getDefaultColumns();

                // Update table headers dynamically
                updateTableHeaders(reportColumns);

                // Populate table with dynamic column mapping
                populateReportTable(data.data, reportColumns);
                showReportTable();

                console.log('Report loaded with source:', data.source);
            } else {
                showReportError(data.error || 'Failed to load data');
            }
        })
        .catch(error => {
            console.error('Error loading Daftar Perkiraan:', error);
            showReportError('Network error: ' + error.message);
        });
}

function loadUniversalReport(reportCode, reportTitle) {
    fetch(`/laporan-laporan/api/reports/${reportCode}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Store column configuration globally
                reportColumns = data.columns || getDefaultColumns();

                // Update table headers dynamically
                updateTableHeaders(reportColumns);

                // Populate table with dynamic column mapping
                populateReportTable(data.data, reportColumns);
                showReportTable();

                console.log('Universal report loaded:', reportCode, 'with source:', data.source);
            } else {
                showReportError(data.error || 'Failed to load report');
            }
        })
        .catch(error => {
            console.error('Error loading universal report:', error);
            showReportError('Network error: ' + error.message);
        });
}

function getDefaultColumns() {
    return [
        {key: 'Perkiraan', label: 'Perkiraan', width: '80px', align: 'left'},
        {key: 'Keterangan', label: 'Keterangan', width: '200px', align: 'left'},
        {key: 'Kelompok', label: 'Kelompok', width: '60px', align: 'center'},
        {key: 'DK', label: 'Debet/Kredit', width: '80px', align: 'center'},
        {key: 'Tipe', label: 'Tipe', width: '60px', align: 'center'},
        {key: 'Valas', label: 'Valas', width: '60px', align: 'center'}
    ];
}

function updateTableHeaders(columns) {
    const thead = document.getElementById('reportTable')?.querySelector('thead tr');
    if (!thead) return;

    // Clear existing headers
    thead.innerHTML = '';

    // Add headers based on column configuration
    columns.forEach(column => {
        const th = document.createElement('th');
        th.textContent = column.label;
        th.style.width = column.width || 'auto';
        th.style.textAlign = column.align || 'left';
        thead.appendChild(th);
    });
}

function populateReportTable(data, columns) {
    const tbody = document.getElementById('reportTableBody');
    if (!tbody) return;

    tbody.innerHTML = '';

    console.log('Populating table with data:', data);
    console.log('Using columns:', columns);

    data.forEach((row, rowIndex) => {
        const tr = document.createElement('tr');

        columns.forEach(column => {
            const td = document.createElement('td');

            // Handle different data structure formats
            let value = '';
            let alignment = column.align || 'left';
            let width = column.width || 'auto';

            // Check if this is processed data structure from DynamicReportService
            if (row[column.key] && typeof row[column.key] === 'object' && row[column.key].value !== undefined) {
                // Processed data from DynamicReportService
                value = row[column.key].value;
                alignment = row[column.key].alignment?.toLowerCase() || alignment;
                width = row[column.key].width ? row[column.key].width + 'px' : width;
            } else if (row[column.key] !== undefined && row[column.key] !== null) {
                // Raw data structure - direct field access
                value = row[column.key];
            } else {
                // Try alternative approaches for getting the value
                value = '';
                console.warn(`Could not find value for column ${column.key} in row ${rowIndex}`, row);
            }

            // Convert value to string and handle null/undefined
            if (value === null || value === undefined) {
                value = '';
            } else {
                value = String(value);
            }

            // Special handling for DK field (Debet/Kredit)
            if (column.key === 'DK') {
                if (value === '0') {
                    value = 'DEBET';
                } else if (value === '1') {
                    value = 'KREDIT';
                }
            }

            // Apply styling
            td.style.textAlign = alignment;
            td.style.width = width;
            td.textContent = value;
            tr.appendChild(td);
        });

        tbody.appendChild(tr);
    });

    console.log(`Populated table with ${data.length} rows`);
}

// Function to update display after kas report data is loaded
function updateKasReportDisplay(data, params) {
    // Update report header with company info
    const reportHeader = document.querySelector('.report-header .company-header');
    if (reportHeader) {
        const h2 = reportHeader.querySelector('h2');
        const h3 = reportHeader.querySelector('h3');
        if (h2) h2.textContent = 'DANA PENSIUN KARYAWAN';
        if (h3) h3.textContent = 'LAPORAN KAS';

        // Show period and details
        const periodDiv = document.getElementById('reportPeriod');
        const detailsDiv = document.getElementById('reportDetails');
        const periodText = document.getElementById('periodText');
        const perkiraanText = document.getElementById('perkiraanText');
        const divisiText = document.getElementById('divisiText');

        if (periodDiv && params.periodeAwal && params.periodeAkhir) {
            periodDiv.style.display = 'block';
            if (periodText) {
                periodText.textContent = `${formatDate(params.periodeAwal)} s/d ${formatDate(params.periodeAkhir)}`;
            }
        }

        if (detailsDiv) {
            detailsDiv.style.display = 'block';
            if (perkiraanText) {
                perkiraanText.textContent = `Perkiraan: ${params.perkiraan || '1201010'} (Kas)`;
            }
            if (divisiText) {
                divisiText.textContent = `Divisi: ${params.divisi || '01'}`;
            }
        }
    }

    // KEEP parameter form visible - don't hide it
    // hideKasParameterForm(); // COMMENTED OUT

    // Update table with real data
    if (data.data && data.data.length > 0) {
        updateTableHeaders(getKasColumns());
        populateReportTable(data.data, getKasColumns());
        showReportTable();
    } else {
        showReportError('Tidak ada data untuk periode yang dipilih');
    }
}

function getKasColumns() {
    return [
        {key: 'Tgl', label: 'Tgl.', width: '80px', align: 'center'},
        {key: 'NoBukti', label: 'No.Bukti', width: '100px', align: 'center'},
        {key: 'Uraian', label: 'URAIAN', width: '200px', align: 'left'},
        {key: 'Perk', label: 'Perk.', width: '60px', align: 'center'},
        {key: 'PenerimaanTunai', label: 'TUNAI', width: '80px', align: 'right'},
        {key: 'PenerimaanCH', label: 'CH / GB', width: '80px', align: 'right'},
        {key: 'PengeluaranTunai', label: 'TUNAI', width: '80px', align: 'right'},
        {key: 'PengeluaranCH', label: 'CH / GB', width: '80px', align: 'right'}
    ];
}

function formatDate(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
}

// Legacy function for backward compatibility
function populateDaftarPerkiraanTable(data) {
    console.warn('Using legacy populateDaftarPerkiraanTable function. Consider updating to use populateReportTable.');
    const defaultColumns = getDefaultColumns();
    populateReportTable(data, defaultColumns);
}

function searchReports(query) {
    const menuSections = document.querySelectorAll('.menu-section');

    menuSections.forEach(section => {
        const submenuItems = section.querySelectorAll('.submenu-item');
        let hasMatch = false;

        submenuItems.forEach(item => {
            const text = item.textContent.toLowerCase();
            if (text.includes(query.toLowerCase())) {
                item.style.display = 'block';
                hasMatch = true;
            } else {
                item.style.display = query ? 'none' : 'block';
            }
        });

        // Show/hide category based on matches
        if (query) {
            section.style.display = hasMatch ? 'block' : 'none';
            if (hasMatch) {
                section.querySelector('.submenu').classList.add('active');
                section.querySelector('.menu-category').classList.add('active');
            }
        } else {
            section.style.display = 'block';
        }
    });
}

function applyFilters() {
    const category = document.getElementById('categoryFilter').value;
    const period = document.getElementById('periodFilter').value;

    alert(`Filter applied:\nCategory: ${category || 'All'}\nPeriod: ${period || 'All'}`);
}

function exportReport(format) {
    if (!selectedReport) {
        alert('Pilih laporan terlebih dahulu');
        return;
    }

    alert(`Exporting ${selectedReport} as ${format.toUpperCase()}`);
    // Here you would implement the actual export functionality
}

function printReport() {
    if (!selectedReport) {
        alert('Pilih laporan terlebih dahulu');
        return;
    }

    window.print();
}

// Initialize dashboard functionality when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Auto-collapse sidebar on mobile
    if (window.innerWidth <= 768) {
        document.getElementById('sidebar').classList.add('collapsed');
        document.getElementById('mainContent').classList.add('expanded');
    }

    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth <= 768) {
            document.getElementById('sidebar').classList.add('collapsed');
            document.getElementById('mainContent').classList.add('expanded');
        }
    });
});

// Export functions to window scope for use by kas-parameter-form component
window.updateKasReportDisplay = updateKasReportDisplay;
window.showReportTable = showReportTable;
window.showReportError = showReportError;
window.showReportLoading = showReportLoading;
window.populateReportTable = populateReportTable;
window.getKasColumns = getKasColumns;
window.formatDate = formatDate;