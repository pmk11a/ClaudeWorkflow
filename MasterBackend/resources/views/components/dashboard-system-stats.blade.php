{{--
    Dashboard System Statistics Component

    Displays system overview statistics in a card format
--}}

<x-card title="System Statistics" icon="fas fa-database">
    <div class="row text-center">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number text-primary">235+</div>
                <div class="stat-label">Database Models</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number text-success">100+</div>
                <div class="stat-label">ERP Tables</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number text-warning">418</div>
                <div class="stat-label">Stored Procedures</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number text-info">100%</div>
                <div class="stat-label">System Health</div>
            </div>
        </div>
    </div>
</x-card>