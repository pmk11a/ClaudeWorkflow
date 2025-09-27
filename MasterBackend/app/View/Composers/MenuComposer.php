<?php

namespace App\View\Composers;

use App\Services\UserPermissionService;
use Illuminate\View\View;
use Illuminate\Support\Facades\Auth;

class MenuComposer
{
    public function __construct(
        private UserPermissionService $permissionService
    ) {}

    /**
     * Bind data to the view.
     */
    public function compose(View $view): void
    {
        \Log::info('MenuComposer compose() called');

        $userMenus = [];

        if (Auth::check()) {
            $user = Auth::user();
            $userMenus = $this->permissionService->getUserMenus($user->USERID);
            \Log::info('MenuComposer: Found ' . count($userMenus) . ' menu groups for user ' . $user->USERID . ' using standard hierarchy');
        } else {
            \Log::info('MenuComposer: User not authenticated');
        }

        $view->with('userMenus', $userMenus);
        \Log::info('MenuComposer: userMenus passed to view with ' . count($userMenus) . ' groups');
    }
}