{{-- Laporan Dashboard Filters Component --}}
<div class="filters" id="dashboard-filters">
    <div class="filter-row">
        <div class="filter-group">
            <label>Kategori Laporan:</label>
            <select id="categoryFilter">
                <option value="">Semua Kategori</option>
                @foreach($reports as $categoryKey => $category)
                <option value="{{ $categoryKey }}">{{ $category['title'] }}</option>
                @endforeach
            </select>
        </div>
        <div class="filter-group">
            <label>Periode:</label>
            <select id="periodFilter">
                <option value="">Pilih Periode</option>
                <option value="current_month">Bulan Ini</option>
                <option value="last_month">Bulan Lalu</option>
                <option value="current_year">Tahun Ini</option>
                <option value="last_year">Tahun Lalu</option>
                <option value="custom">Custom</option>
            </select>
        </div>
        <button class="apply-filter-btn" onclick="applyFilters()">
            🔍 Apply Filter
        </button>
    </div>
</div>

<script>
// Hide filters when specific reports are loaded
document.addEventListener('DOMContentLoaded', function() {
    // Check if report is currently displayed
    const reportContainer = document.querySelector('#reportContent');
    const filtersContainer = document.querySelector('#dashboard-filters');

    if (reportContainer && filtersContainer) {
        // Create observer to watch for report content changes
        const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.type === 'childList') {
                    const hasReportContent = reportContainer.children.length > 0 &&
                                           reportContainer.querySelector('table') !== null;

                    if (hasReportContent) {
                        // Hide filters when report is displayed
                        filtersContainer.style.display = 'none';
                        console.log('Filters hidden - report loaded');
                    } else {
                        // Show filters when no report is displayed
                        filtersContainer.style.display = 'block';
                        console.log('Filters shown - no report');
                    }
                }
            });
        });

        // Start observing
        observer.observe(reportContainer, { childList: true, subtree: true });

        // Initial check
        const hasReportContent = reportContainer.children.length > 0 &&
                                reportContainer.querySelector('table') !== null;
        if (hasReportContent) {
            filtersContainer.style.display = 'none';
            console.log('Initial check: Filters hidden - report already loaded');
        } else {
            console.log('Initial check: Filters visible - no report loaded');
        }
    } else {
        console.log('Containers not found:', {
            reportContainer: !!reportContainer,
            filtersContainer: !!filtersContainer
        });
    }
});
</script>