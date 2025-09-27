<?php

namespace App\Providers;

use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;

// Import Models
use App\Models\DbPO;
use App\Models\DbPODET;
use App\Models\DbBELIDET;
use App\Models\DbTRANSFERDET;
use App\Models\DbKOREKSIDET;

// Import Observers
use App\Observers\DbPOObserver;
use App\Observers\DbPODETObserver;
use App\Observers\DbBELIDETObserver;
use App\Observers\DbTRANSFERDETObserver;
use App\Observers\DbKOREKSIDETObserver;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event listener mappings for the application.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
    ];

    /**
     * Register any events for your application.
     *
     * @return void
     */
    public function boot()
    {
        // Register Model Observers for tables with database triggers
        
        // Purchase Order
        DbPO::observe(DbPOObserver::class);
        DbPODET::observe(DbPODETObserver::class);
        
        // Purchase/Buying
        DbBELIDET::observe(DbBELIDETObserver::class);
        
        // Inventory Transfer
        DbTRANSFERDET::observe(DbTRANSFERDETObserver::class);
        
        // Stock Correction
        DbKOREKSIDET::observe(DbKOREKSIDETObserver::class);
        
        // Log observer registration
        if (app()->environment('local')) {
            \Log::info('Database Trigger Observers registered', [
                'observers' => [
                    'DbPOObserver',
                    'DbPODETObserver', 
                    'DbBELIDETObserver',
                    'DbTRANSFERDETObserver',
                    'DbKOREKSIDETObserver'
                ]
            ]);
        }
    }
}
