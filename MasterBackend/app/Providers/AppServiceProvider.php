<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\View;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        // Register Report Services for dependency injection
        $this->app->bind(\App\Services\LaporanService::class, function ($app) {
            return new \App\Services\LaporanService();
        });

        $this->app->bind(\App\Services\LaporanParameterBuilder::class, function ($app) {
            return new \App\Services\LaporanParameterBuilder($app->make(\App\Services\LaporanService::class));
        });

        $this->app->bind(\App\Services\LaporanExportService::class, function ($app) {
            return new \App\Services\LaporanExportService();
        });

        $this->app->bind(\App\Services\LaporanConfigService::class, function ($app) {
            return new \App\Services\LaporanConfigService();
        });

        $this->app->bind(\App\Services\MenuReportService::class, function ($app) {
            return new \App\Services\MenuReportService();
        });

        $this->app->bind(\App\Services\DynamicReportService::class, function ($app) {
            return new \App\Services\DynamicReportService(
                $app->make(\App\Services\ReportFilterService::class)
            );
        });

        // Register Filter Services for dynamic filter system
        $this->app->bind(\App\Services\ReportFilterService::class, function ($app) {
            return new \App\Services\ReportFilterService();
        });

        $this->app->bind(\App\Services\FilterComponentFactory::class, function ($app) {
            return new \App\Services\FilterComponentFactory();
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        // Register view composer for admin layout
        View::composer('layouts.admin', \App\View\Composers\MenuComposer::class);

        // Debug log
        \Log::info('AppServiceProvider boot() executed - MenuComposer registered');
    }
}
