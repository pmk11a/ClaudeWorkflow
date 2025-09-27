{{--
    Dashboard System Information Component

    Displays technical system information in a card format
--}}

<x-card title="System Information" icon="fas fa-server">
    <div class="row">
        <div class="col-md-6">
            <ul class="list-unstyled">
                <li><strong>System:</strong> DAPEN Smart Accounting</li>
                <li><strong>Framework:</strong> Laravel 9.0</li>
                <li><strong>Database:</strong> SQL Server</li>
                <li><strong>Environment:</strong> {{ app()->environment() }}</li>
            </ul>
        </div>
        <div class="col-md-6">
            <ul class="list-unstyled">
                <li><strong>PHP Version:</strong> {{ PHP_VERSION }}</li>
                <li><strong>Laravel Version:</strong> {{ app()->version() }}</li>
                <li><strong>Server Time:</strong> {{ now()->format('d/m/Y H:i:s') }}</li>
                <li><strong>Timezone:</strong> {{ config('app.timezone') }}</li>
            </ul>
        </div>
    </div>
</x-card>