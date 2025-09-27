/* DAPEN ERP - DataTable Component Scripts */
/* Extracted from data-table.blade.php for clean code architecture */

/**
 * Initialize DataTable for a specific table
 * @param {string} tableId - The ID of the table element
 * @param {object} options - DataTable configuration options
 */
function initializeDataTable(tableId, options = {}) {
    document.addEventListener('DOMContentLoaded', function() {
        const table = $('#' + tableId);

        if (table.length && $.fn.DataTable) {
            const defaultConfig = {
                responsive: true,
                pageLength: options.pageLength || 25,
                order: [[0, 'asc']],
                language: {
                    search: "",
                    searchPlaceholder: "Search records...",
                    lengthMenu: "Show _MENU_ entries",
                    info: "Showing _START_ to _END_ of _TOTAL_ entries",
                    infoEmpty: "Showing 0 to 0 of 0 entries",
                    infoFiltered: "(filtered from _MAX_ total entries)",
                    zeroRecords: "No matching records found",
                    emptyTable: "No data available in table",
                    paginate: {
                        first: "First",
                        last: "Last",
                        next: "Next",
                        previous: "Previous"
                    }
                },
                dom: 'rt<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>',
                drawCallback: function() {
                    // Re-initialize tooltips after table redraw
                    $('[data-bs-toggle="tooltip"]').tooltip();
                }
            };

            // Merge custom options with defaults
            const config = Object.assign({}, defaultConfig, options);

            // Add export buttons if exportable
            if (options.exportable) {
                config.buttons = [
                    {
                        extend: 'copy',
                        className: 'btn btn-outline-secondary btn-sm me-1',
                        text: '<i class="fas fa-copy"></i> Copy'
                    },
                    {
                        extend: 'csv',
                        className: 'btn btn-outline-secondary btn-sm me-1',
                        text: '<i class="fas fa-file-csv"></i> CSV'
                    },
                    {
                        extend: 'excel',
                        className: 'btn btn-outline-secondary btn-sm me-1',
                        text: '<i class="fas fa-file-excel"></i> Excel'
                    },
                    {
                        extend: 'pdf',
                        className: 'btn btn-outline-secondary btn-sm me-1',
                        text: '<i class="fas fa-file-pdf"></i> PDF'
                    },
                    {
                        extend: 'print',
                        className: 'btn btn-outline-secondary btn-sm',
                        text: '<i class="fas fa-print"></i> Print'
                    }
                ];
                config.dom = 'B' + config.dom;
            }

            const dataTable = table.DataTable(config);

            // Custom search integration
            $('input[type="search"]').on('keyup', function() {
                dataTable.search(this.value).draw();
            });

            // Custom length change integration
            $('select[name="' + tableId + '_length"]').on('change', function() {
                dataTable.page.len(this.value).draw();
            });

            return dataTable;
        }
    });
}

/**
 * Auto-initialize all data tables with data-table-auto attribute
 */
document.addEventListener('DOMContentLoaded', function() {
    const autoTables = document.querySelectorAll('[data-table-auto="true"]');
    autoTables.forEach(function(table) {
        const tableId = table.getAttribute('id');
        const exportable = table.getAttribute('data-export') === 'true';
        const pageLength = parseInt(table.getAttribute('data-page-length')) || 25;

        if (tableId) {
            initializeDataTable(tableId, {
                exportable: exportable,
                pageLength: pageLength
            });
        }
    });
});