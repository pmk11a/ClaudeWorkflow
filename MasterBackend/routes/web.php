<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PermissionController;
use App\Http\Controllers\DiagnosticController;
use App\Http\Controllers\LaporanController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return redirect()->route('login');
});

// Authentication Routes
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::get('/dashboard', [AuthController::class, 'dashboard'])->name('dashboard');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Diagnostic Routes (for debugging)
Route::get('/diagnostics', [DiagnosticController::class, 'index'])->name('diagnostics.index');
Route::get('/diagnostics/api', [DiagnosticController::class, 'api'])->name('diagnostics.api');
Route::post('/diagnostics/test-user', [DiagnosticController::class, 'testUser'])->name('diagnostics.test-user');

// Protected Routes (require authentication)
Route::middleware(['web'])->group(function () {
    
    // User Management Routes
    Route::resource('users', UserController::class);
    Route::post('/users/{user}/toggle-status', [UserController::class, 'toggleStatus'])->name('users.toggle-status');
    Route::post('/users/copy-permissions', [UserController::class, 'copyPermissions'])->name('users.copy-permissions');
    Route::get('/users/select', [UserController::class, 'getUsersForSelect'])->name('users.select');
    Route::get('/users/export', [UserController::class, 'export'])->name('users.export');
    
    // Permission Management Routes
    Route::get('/permissions/{user}/matrix', [PermissionController::class, 'matrix'])->name('permissions.matrix');
    Route::post('/permissions/{user}/update', [PermissionController::class, 'updatePermissions'])->name('permissions.update');
    Route::post('/permissions/{user}/bulk-update', [PermissionController::class, 'bulkUpdatePermissions'])->name('permissions.bulk-update');
    Route::post('/permissions/{user}/reset-default', [PermissionController::class, 'resetToDefault'])->name('permissions.reset-default');
    Route::get('/permissions/{user}/export', [PermissionController::class, 'exportUserPermissions'])->name('permissions.export-user');
    
    // Bulk Permission Management
    Route::get('/permissions/bulk', [PermissionController::class, 'bulk'])->name('permissions.bulk');
    Route::post('/permissions/bulk-apply', [PermissionController::class, 'applyBulkPermissions'])->name('permissions.bulk-apply');
    Route::get('/permissions/{user}/permissions', [PermissionController::class, 'getUserPermissions'])->name('permissions.get-user');
    Route::get('/permissions/{user}/{menuCode}/check/{permission?}', [PermissionController::class, 'checkPermission'])->name('permissions.check');
    Route::get('/permissions/menu-hierarchy', [PermissionController::class, 'getMenuHierarchy'])->name('permissions.menu-hierarchy');
});

// Laporan-laporan Routes Group
Route::prefix('/laporan-laporan')->name('laporan-laporan.')->group(function () {
    // Report Form Routes
    Route::get('/laporan-admin', [LaporanController::class, 'showReportForm'])->name('laporan.form');
    Route::get('/laporan-admin/{reportCode}', [LaporanController::class, 'showSpecificReportForm'])->name('laporan.specific');

    // Filter Management API Routes
    Route::post('/api/reports/{reportCode}/filters', [LaporanController::class, 'createReportFilter'])->name('filters.create');
    Route::put('/api/reports/{reportCode}/filters/{filterId}', [LaporanController::class, 'updateReportFilter'])->name('filters.update');
    Route::delete('/api/reports/{reportCode}/filters/{filterId}', [LaporanController::class, 'deleteReportFilter'])->name('filters.delete');
    Route::get('/api/reports/{reportCode}/filters', [LaporanController::class, 'getReportFilters'])->name('filters.list');

    // End-user Report Routes (simple interface)
    Route::get('/laporan/{reportCode}', [LaporanController::class, 'showEndUserReport'])->name('laporan.enduser');
    Route::post('/laporan/{reportCode}/generate', [LaporanController::class, 'generateEndUserReport'])->name('laporan.enduser.generate');

    // ERP-style Dashboard
    Route::get('/laporan-clean', [LaporanController::class, 'showERPDashboard'])->name('laporan.erp.dashboard');

    // Specific Report Interfaces
    Route::get('/kas-harian', [LaporanController::class, 'showKasHarian'])->name('laporan.kas.harian');

    // API for Daftar Perkiraan
    Route::get('/api/daftar-perkiraan', [LaporanController::class, 'getDaftarPerkiraan'])->name('api.daftar.perkiraan');

    // Dynamic Report System API
    Route::get('/api/reports', [LaporanController::class, 'getDynamicReportsList'])->name('api.reports.list');
    Route::get('/api/reports/{reportCode}', [LaporanController::class, 'getUniversalReport'])->name('api.reports.data');
    Route::post('/api/reports/{reportCode}', [LaporanController::class, 'generateKasHarian'])->name('api.reports.generate');
    Route::get('/api/reports/{reportCode}/config', [LaporanController::class, 'getReportConfiguration'])->name('api.reports.config');

    // Filter Management API
    Route::get('/api/reports/{reportCode}/filters', [LaporanController::class, 'getReportFilters'])->name('api.reports.filters');
    Route::get('/api/reports/{reportCode}/filters/{filterName}/options', [LaporanController::class, 'getFilterOptions'])->name('api.reports.filter.options');
    Route::post('/api/reports/{reportCode}/filters', [LaporanController::class, 'createReportFilter'])->name('api.reports.filters.create');
    Route::post('/api/reports/{reportCode}/filters/bulk', [LaporanController::class, 'bulkCreateReportFilters'])->name('api.reports.filters.bulk');
    Route::put('/api/reports/{reportCode}/filters/{filterId}', [LaporanController::class, 'updateReportFilter'])->name('api.reports.filters.update');
    Route::delete('/api/reports/{reportCode}/filters/{filterId}', [LaporanController::class, 'deleteReportFilter'])->name('api.reports.filters.delete');
});

// Database Test Route
Route::get('/test-db', function () {
    try {
        DB::connection()->getPdo();
        $result = DB::select('SELECT 1 as test');
        return response()->json([
            'status' => 'success',
            'message' => 'Database connection successful',
            'test_query' => $result[0]->test
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Database connection failed: ' . $e->getMessage()
        ], 500);
    }
});
