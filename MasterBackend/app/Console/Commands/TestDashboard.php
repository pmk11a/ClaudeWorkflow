<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\DbFLPASS;
use App\Services\UserPermissionService;
use Illuminate\Support\Facades\Auth;

class TestDashboard extends Command
{
    protected $signature = 'test:dashboard';
    protected $description = 'Test dashboard sidebar menu generation';

    public function handle()
    {
        $this->info('=== TESTING DASHBOARD SIDEBAR MENU ===');

        // Get user
        $user = DbFLPASS::find('SA');
        if (!$user) {
            $this->error('User SA not found');
            return 1;
        }

        $this->info("User: {$user->FullName}");

        // Test UserPermissionService directly
        $service = new UserPermissionService();
        $userMenus = $service->getUserMenus('SA');

        $this->info("Menu groups found: " . count($userMenus));

        foreach ($userMenus as $group) {
            $this->line("📁 {$group['title']} ({$group['icon']}) - " . count($group['items']) . " items");
            foreach (array_slice($group['items'], 0, 3) as $item) {
                $this->line("   - {$item['title']} ({$item['code']})");
            }
            if (count($group['items']) > 3) {
                $this->line("   ... and " . (count($group['items']) - 3) . " more");
            }
        }

        // Set auth and test view composer
        Auth::login($user);

        try {
            $this->info("\n=== TESTING VIEW RENDERING ===");

            // Create simple test view
            $testContent = '@extends("layouts.admin")
@section("content")
<div class="test-content">
    @if(isset($userMenus))
        <p>✅ userMenus available with {{ count($userMenus) }} groups</p>
        @foreach($userMenus as $group)
            <p>Group: {{ $group["title"] }}</p>
        @endforeach
    @else
        <p>❌ userMenus NOT available</p>
    @endif
</div>
@endsection';

            $testFile = resource_path('views/test-menu.blade.php');
            file_put_contents($testFile, $testContent);

            $html = view('test-menu')->render();

            // Check results
            if (strpos($html, '✅ userMenus available') !== false) {
                $this->info('✅ SUCCESS: userMenus found in rendered view');

                // Extract and display sidebar content
                if (preg_match('/<aside class="sidebar">(.*?)<\/aside>/s', $html, $matches)) {
                    $sidebarContent = $matches[1];
                    $menuCount = substr_count($sidebarContent, 'data-bs-toggle="collapse"');
                    $this->info("✅ Sidebar found with {$menuCount} collapsible menu groups");

                    if (strpos($sidebarContent, 'Berkas') !== false) {
                        $this->info('✅ Berkas menu group found in sidebar');
                    }
                    if (strpos($sidebarContent, 'Jendela') !== false) {
                        $this->info('✅ Jendela menu group found in sidebar');
                    }

                } else {
                    $this->warn('⚠️  Sidebar structure not found in HTML');
                }

            } else {
                $this->error('❌ FAILED: userMenus NOT found in rendered view');
            }

            // Save HTML for inspection
            $outputFile = base_path('test-dashboard-output.html');
            file_put_contents($outputFile, $html);
            $this->info("HTML saved to: {$outputFile}");

            // Clean up
            unlink($testFile);

        } catch (\Exception $e) {
            $this->error("Error rendering view: " . $e->getMessage());
        }

        $this->info('=== TEST COMPLETE ===');
        return 0;
    }
}