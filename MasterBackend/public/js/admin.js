/**
 * DAPEN Admin Dashboard JavaScript
 * Clean, modular JavaScript for admin functionality
 */

// Main App Object
const DapenAdmin = {
    // Configuration
    config: {
        baseUrl: window.location.origin,
        apiUrl: window.location.origin + '/api',
        csrfToken: document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    },

    // Initialize application
    init() {
        this.setupCSRF();
        this.setupSidebar();
        this.setupPeriodSelector();
        this.setupMenuSearch();
        this.setupTreeviewMenu();
        this.setupDataTables();
        this.setupForms();
        this.setupTooltips();
        this.setupNotifications();
        console.log('DapenAdmin initialized');
    },

    // Setup CSRF token for AJAX requests
    setupCSRF() {
        if (this.config.csrfToken) {
            $.ajaxSetup({
                headers: {
                    'X-CSRF-TOKEN': this.config.csrfToken
                }
            });
        }
    },

    // Sidebar functionality
    setupSidebar() {
        const sidebar = document.querySelector('.sidebar');
        const mainContent = document.querySelector('.main-content');
        const toggleBtn = document.querySelector('.sidebar-toggle');

        if (toggleBtn) {
            toggleBtn.addEventListener('click', () => {
                sidebar?.classList.toggle('collapsed');
                mainContent?.classList.toggle('expanded');

                // Save state to localStorage
                const isCollapsed = sidebar?.classList.contains('collapsed');
                localStorage.setItem('sidebar-collapsed', isCollapsed);
            });
        }

        // Restore sidebar state
        const savedState = localStorage.getItem('sidebar-collapsed');
        if (savedState === 'true') {
            sidebar?.classList.add('collapsed');
            mainContent?.classList.add('expanded');
        }

        // Active menu highlighting
        this.setActiveMenu();
    },

    // Setup period selector functionality
    setupPeriodSelector() {
        const savePeriodBtn = document.getElementById('savePeriod');
        const periodModal = document.getElementById('periodModal');
        const periodText = document.querySelector('.period-text');

        if (!savePeriodBtn || !periodModal || !periodText) return;

        // Load saved period from localStorage
        const savedPeriod = this.getSavedPeriod();
        if (savedPeriod) {
            this.updatePeriodDisplay(savedPeriod.month, savedPeriod.year);
            this.updatePeriodForm(savedPeriod.month, savedPeriod.year);
        }

        // Save period when clicking save button
        savePeriodBtn.addEventListener('click', () => {
            const month = document.getElementById('periodMonth').value;
            const year = document.getElementById('periodYear').value;

            if (month && year) {
                this.savePeriod(month, year);
                this.updatePeriodDisplay(month, year);

                // Close modal
                const modal = bootstrap.Modal.getInstance(periodModal);
                if (modal) modal.hide();

                // Show success notification
                this.showNotification('Periode berhasil diubah', 'success');
            }
        });
    },

    // Get saved period from localStorage
    getSavedPeriod() {
        try {
            const period = localStorage.getItem('dapen_work_period');
            return period ? JSON.parse(period) : null;
        } catch (e) {
            return null;
        }
    },

    // Save period to localStorage
    savePeriod(month, year) {
        const period = { month, year };
        localStorage.setItem('dapen_work_period', JSON.stringify(period));
    },

    // Update period display
    updatePeriodDisplay(month, year) {
        const periodText = document.querySelector('.period-text');
        if (periodText) {
            periodText.textContent = `Periode : ${month} Bulan ${year} Tahun`;
        }
    },

    // Update period form values
    updatePeriodForm(month, year) {
        const monthSelect = document.getElementById('periodMonth');
        const yearSelect = document.getElementById('periodYear');

        if (monthSelect) monthSelect.value = month;
        if (yearSelect) yearSelect.value = year;
    },

    // Setup menu search functionality
    setupMenuSearch() {
        const searchInput = document.getElementById('menuSearch');
        if (!searchInput) return;

        const debouncedSearch = this.debounce((query) => {
            this.filterMenu(query);
        }, 300);

        searchInput.addEventListener('input', (e) => {
            debouncedSearch(e.target.value);
        });

        // Clear search on escape
        searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                searchInput.value = '';
                this.filterMenu('');
            }
        });
    },

    // Filter menu items based on search query
    filterMenu(query) {
        const menuItems = document.querySelectorAll('#sidebarMenu .nav-item');
        const searchQuery = query.toLowerCase().trim();

        menuItems.forEach(item => {
            const menuTitle = item.dataset.menuTitle || '';
            const menuText = item.querySelector('.menu-text')?.textContent.toLowerCase() || '';

            if (searchQuery === '') {
                // Show all items and remove highlights
                item.classList.remove('search-hidden');
                this.removeHighlights(item);

                // Collapse all expanded menus when search is cleared
                const treeview = item.querySelector('.nav-treeview');
                if (treeview) {
                    treeview.classList.remove('show');
                    item.classList.remove('menu-open');
                }
            } else {
                const isMatch = menuTitle.includes(searchQuery) || menuText.includes(searchQuery);

                if (isMatch) {
                    item.classList.remove('search-hidden');
                    this.highlightMatch(item, searchQuery);

                    // Expand parent if this is a submenu item
                    const parentTreeview = item.closest('.nav-treeview');
                    if (parentTreeview) {
                        parentTreeview.classList.add('show');
                        const parentItem = parentTreeview.closest('.nav-item.has-treeview');
                        if (parentItem) {
                            parentItem.classList.add('menu-open');
                        }
                    }
                } else {
                    item.classList.add('search-hidden');
                    this.removeHighlights(item);
                }
            }
        });
    },

    // Highlight matching text
    highlightMatch(item, query) {
        const menuText = item.querySelector('.menu-text');
        if (!menuText || !query) return;

        const text = menuText.textContent;
        const regex = new RegExp(`(${query})`, 'gi');
        const highlightedText = text.replace(regex, '<span class="menu-highlight">$1</span>');
        menuText.innerHTML = highlightedText;
    },

    // Remove highlights
    removeHighlights(item) {
        const menuText = item.querySelector('.menu-text');
        if (!menuText) return;

        const text = menuText.textContent;
        menuText.innerHTML = text;
    },

    // Setup treeview menu functionality
    setupTreeviewMenu() {
        document.addEventListener('click', (e) => {
            const menuToggle = e.target.closest('.menu-toggle');
            if (!menuToggle) return;

            e.preventDefault();
            e.stopPropagation();

            const parentItem = menuToggle.closest('.nav-item.has-treeview');
            const targetId = menuToggle.dataset.target;
            const treeview = document.querySelector(targetId);

            if (!parentItem || !treeview) return;

            // Toggle the menu
            const isOpen = parentItem.classList.contains('menu-open');

            if (isOpen) {
                // Close menu
                parentItem.classList.remove('menu-open');
                treeview.classList.remove('show');
            } else {
                // Check if this is a nested menu (submenu)
                const isNested = parentItem.closest('.nav-treeview');

                if (!isNested) {
                    // This is a top-level menu - close other top-level menus (accordion behavior)
                    document.querySelectorAll('.nav-item.has-treeview.menu-open').forEach(openItem => {
                        // Only close items that are not nested and not the current item
                        if (openItem !== parentItem && !openItem.closest('.nav-treeview')) {
                            openItem.classList.remove('menu-open');
                            const openTreeview = openItem.querySelector('.nav-treeview');
                            if (openTreeview) {
                                openTreeview.classList.remove('show');
                            }
                        }
                    });
                }
                // For nested menus, don't close siblings to allow multiple submenu open

                // Open menu
                parentItem.classList.add('menu-open');
                treeview.classList.add('show');
            }

            // Save menu state
            this.saveMenuState();
        });

        // Restore menu states
        this.restoreMenuState();
    },

    // Save menu states to localStorage
    saveMenuState() {
        const openMenus = [];
        document.querySelectorAll('.nav-item.has-treeview.menu-open').forEach(item => {
            const toggle = item.querySelector('.menu-toggle');
            const targetId = toggle?.dataset.target;
            if (targetId) {
                openMenus.push(targetId);
            }
        });
        localStorage.setItem('dapen-open-menus', JSON.stringify(openMenus));
    },

    // Restore menu states from localStorage
    restoreMenuState() {
        const savedMenus = localStorage.getItem('dapen-open-menus');
        if (!savedMenus) return;

        try {
            const openMenus = JSON.parse(savedMenus);
            openMenus.forEach(targetId => {
                const treeview = document.querySelector(targetId);
                const parentItem = treeview?.closest('.nav-item.has-treeview');

                if (treeview && parentItem) {
                    parentItem.classList.add('menu-open');
                    treeview.classList.add('show');
                }
            });
        } catch (e) {
            console.warn('Failed to restore menu state:', e);
        }
    },

    // Set active menu based on current URL
    setActiveMenu() {
        const currentPath = window.location.pathname;
        const menuLinks = document.querySelectorAll('.nav-sidebar .nav-link');

        menuLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href && currentPath.includes(href) && href !== '/') {
                link.classList.add('active');
                // Also expand parent menu if exists
                const parentCollapse = link.closest('.collapse');
                if (parentCollapse) {
                    parentCollapse.classList.add('show');
                }
            }
        });
    },

    // Setup DataTables
    setupDataTables() {
        $('.data-table').each(function() {
            const table = $(this);
            const config = {
                responsive: true,
                lengthChange: true,
                autoWidth: false,
                pageLength: 25,
                lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                language: {
                    search: "Search:",
                    lengthMenu: "Show _MENU_ entries",
                    info: "Showing _START_ to _END_ of _TOTAL_ entries",
                    infoEmpty: "Showing 0 to 0 of 0 entries",
                    infoFiltered: "(filtered from _MAX_ total entries)",
                    paginate: {
                        first: "First",
                        last: "Last",
                        next: "Next",
                        previous: "Previous"
                    }
                },
                dom: '<"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6"f>>' +
                     '<"row"<"col-sm-12"tr>>' +
                     '<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>',
                drawCallback: function() {
                    // Re-initialize tooltips after table redraw
                    DapenAdmin.setupTooltips();
                }
            };

            // Add export buttons if data-export attribute exists
            if (table.data('export')) {
                config.buttons = [
                    {
                        extend: 'copy',
                        className: 'btn btn-outline-secondary btn-sm'
                    },
                    {
                        extend: 'csv',
                        className: 'btn btn-outline-secondary btn-sm'
                    },
                    {
                        extend: 'excel',
                        className: 'btn btn-outline-secondary btn-sm'
                    },
                    {
                        extend: 'pdf',
                        className: 'btn btn-outline-secondary btn-sm'
                    },
                    {
                        extend: 'print',
                        className: 'btn btn-outline-secondary btn-sm'
                    }
                ];
                config.dom = '<"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6"f>>' +
                            '<"row"<"col-sm-12 col-md-6"B>>' +
                            '<"row"<"col-sm-12"tr>>' +
                            '<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>';
            }

            table.DataTable(config);
        });
    },

    // Setup form functionality
    setupForms() {
        // Form validation
        $('.needs-validation').each(function() {
            const form = this;

            form.addEventListener('submit', function(event) {
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            });
        });

        // Auto-submit forms with class 'auto-submit'
        $('.auto-submit').on('change', 'select, input', function() {
            $(this).closest('form').submit();
        });

        // Confirm delete actions
        $(document).on('click', '.btn-delete', function(e) {
            e.preventDefault();
            const url = $(this).attr('href') || $(this).data('url');
            const title = $(this).data('title') || 'Are you sure?';
            const text = $(this).data('text') || 'This action cannot be undone.';

            DapenAdmin.confirmDelete(url, title, text);
        });

        // Toggle password visibility
        $(document).on('click', '.password-toggle', function() {
            const target = $(this).data('target');
            const input = $(target);
            const icon = $(this).find('i');

            if (input.attr('type') === 'password') {
                input.attr('type', 'text');
                icon.removeClass('fa-eye').addClass('fa-eye-slash');
            } else {
                input.attr('type', 'password');
                icon.removeClass('fa-eye-slash').addClass('fa-eye');
            }
        });
    },

    // Setup tooltips
    setupTooltips() {
        if (typeof bootstrap !== 'undefined') {
            // Initialize Bootstrap tooltips
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            tooltipTriggerList.map(function(tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });

            // Initialize Bootstrap popovers
            const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
            popoverTriggerList.map(function(popoverTriggerEl) {
                return new bootstrap.Popover(popoverTriggerEl);
            });
        }
    },

    // Notification system
    setupNotifications() {
        // Auto-hide alerts after 5 seconds
        $('.alert:not(.alert-permanent)').each(function() {
            const alert = $(this);
            setTimeout(() => {
                alert.fadeOut();
            }, 5000);
        });
    },

    // Utility Methods
    showLoading(element) {
        const $element = $(element);
        $element.addClass('loading');
        $element.prop('disabled', true);
    },

    hideLoading(element) {
        const $element = $(element);
        $element.removeClass('loading');
        $element.prop('disabled', false);
    },

    // SweetAlert2 confirmation dialog
    confirmDelete(url, title = 'Are you sure?', text = 'This action cannot be undone.') {
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                title: title,
                text: text,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    if (url.startsWith('http')) {
                        window.location.href = url;
                    } else {
                        // Handle AJAX delete
                        this.performDelete(url);
                    }
                }
            });
        } else {
            // Fallback to native confirm
            if (confirm(title + '\n' + text)) {
                window.location.href = url;
            }
        }
    },

    // Perform AJAX delete
    performDelete(url) {
        $.ajax({
            url: url,
            method: 'DELETE',
            dataType: 'json',
            success: function(response) {
                if (response.success) {
                    DapenAdmin.showNotification('Success!', response.message || 'Item deleted successfully.', 'success');
                    // Reload the page or remove the row
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                } else {
                    DapenAdmin.showNotification('Error!', response.message || 'Delete failed.', 'error');
                }
            },
            error: function(xhr) {
                let message = 'An error occurred while deleting.';
                if (xhr.responseJSON && xhr.responseJSON.message) {
                    message = xhr.responseJSON.message;
                }
                DapenAdmin.showNotification('Error!', message, 'error');
            }
        });
    },

    // Show notification
    showNotification(title, message, type = 'info') {
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                title: title,
                text: message,
                icon: type,
                timer: 3000,
                showConfirmButton: false,
                toast: true,
                position: 'top-end'
            });
        } else {
            // Fallback to alert
            alert(title + '\n' + message);
        }
    },

    // AJAX form submission
    submitForm(form, options = {}) {
        const $form = $(form);
        const url = options.url || $form.attr('action');
        const method = options.method || $form.attr('method') || 'POST';
        const data = options.data || $form.serialize();

        this.showLoading($form.find('[type="submit"]'));

        $.ajax({
            url: url,
            method: method,
            data: data,
            dataType: 'json',
            success: function(response) {
                if (response.success) {
                    DapenAdmin.showNotification('Success!', response.message, 'success');
                    if (options.redirect) {
                        setTimeout(() => {
                            window.location.href = options.redirect;
                        }, 1000);
                    }
                    if (options.callback) {
                        options.callback(response);
                    }
                } else {
                    DapenAdmin.showNotification('Error!', response.message, 'error');
                }
            },
            error: function(xhr) {
                let message = 'An error occurred.';
                if (xhr.responseJSON) {
                    if (xhr.responseJSON.message) {
                        message = xhr.responseJSON.message;
                    } else if (xhr.responseJSON.errors) {
                        // Handle validation errors
                        const errors = Object.values(xhr.responseJSON.errors).flat();
                        message = errors.join('\n');
                    }
                }
                DapenAdmin.showNotification('Error!', message, 'error');
            },
            complete: function() {
                DapenAdmin.hideLoading($form.find('[type="submit"]'));
            }
        });
    },

    // Format currency
    formatCurrency(amount, currency = 'IDR') {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: currency
        }).format(amount);
    },

    // Format date
    formatDate(date, format = 'dd/MM/yyyy') {
        if (!date) return '-';
        const d = new Date(date);
        return d.toLocaleDateString('id-ID');
    },

    // Debounce function for search inputs
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
};

// Initialize when DOM is ready
$(document).ready(function() {
    DapenAdmin.init();
});

// Export for global access
window.DapenAdmin = DapenAdmin;