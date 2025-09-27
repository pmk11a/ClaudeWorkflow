<?php

namespace App\Console\Commands;

use App\Models\DbFLPASS;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DiagnoseDatabase extends Command
{
    protected $signature = 'diagnose:database {--username=} {--password=} {--test-connection} {--list-users}';

    protected $description = 'Diagnose database connection and authentication issues';

    public function handle()
    {
        $this->info('=== Database Connection & Authentication Diagnostics ===');
        $this->newLine();

        // Test database connection
        if ($this->option('test-connection') || !$this->option('username')) {
            $this->testDatabaseConnection();
        }

        // List users if requested
        if ($this->option('list-users')) {
            $this->listUsers();
        }

        // Test specific user authentication
        if ($this->option('username')) {
            $this->testUserAuthentication($this->option('username'), $this->option('password'));
        }
    }

    private function testDatabaseConnection()
    {
        $this->info('Testing database connection...');
        
        try {
            $pdo = DB::connection()->getPdo();
            $this->info('✓ Database connection successful');
            
            // Get database info
            $serverInfo = $pdo->getAttribute(\PDO::ATTR_SERVER_INFO);
            $this->info("Server Info: {$serverInfo}");
            
            $driverName = $pdo->getAttribute(\PDO::ATTR_DRIVER_NAME);
            $this->info("Driver: {$driverName}");
            
            $serverVersion = $pdo->getAttribute(\PDO::ATTR_SERVER_VERSION);
            $this->info("Server Version: {$serverVersion}");
            
            // Test a simple query
            $result = DB::select('SELECT @@VERSION as version');
            $this->info("Database Version: " . $result[0]->version);
            
        } catch (\Exception $e) {
            $this->error('✗ Database connection failed');
            $this->error("Error: " . $e->getMessage());
            $this->newLine();
            
            // Show connection configuration
            $this->info('Current database configuration:');
            $config = config('database.connections.sqlsrv');
            $this->table(
                ['Setting', 'Value'],
                [
                    ['Host', $config['host']],
                    ['Port', $config['port']],
                    ['Database', $config['database']],
                    ['Username', $config['username']],
                    ['Encrypt', $config['encrypt'] ? 'true' : 'false'],
                    ['Trust Server Certificate', $config['trust_server_certificate'] ? 'true' : 'false'],
                ]
            );
        }
        $this->newLine();
    }

    private function listUsers()
    {
        $this->info('Listing active users...');
        
        try {
            $users = DbFLPASS::where('STATUS', 1)->take(10)->get();
            
            if ($users->isEmpty()) {
                $this->warn('No active users found');
                return;
            }

            $userData = [];
            foreach ($users as $user) {
                $userData[] = [
                    'USERID' => $user->USERID,
                    'FullName' => $user->FullName ?? 'N/A',
                    'Status' => $user->STATUS ? 'Active' : 'Inactive',
                    'Has Password' => !empty($user->UID) ? 'Yes' : 'No',
                    'Password Type' => $this->detectPasswordType($user->UID),
                ];
            }

            $this->table(
                ['User ID', 'Full Name', 'Status', 'Has Password', 'Password Type'],
                $userData
            );
            
        } catch (\Exception $e) {
            $this->error('Failed to list users: ' . $e->getMessage());
        }
        $this->newLine();
    }

    private function testUserAuthentication($username, $password = null)
    {
        $this->info("Testing authentication for user: {$username}");
        
        try {
            $user = DbFLPASS::where('USERID', strtoupper($username))->first();
            
            if (!$user) {
                $this->error('✗ User not found');
                return;
            }

            $this->info('✓ User found');
            $this->table(
                ['Field', 'Value'],
                [
                    ['User ID', $user->USERID],
                    ['Full Name', $user->FullName ?? 'N/A'],
                    ['Status', $user->STATUS ? 'Active' : 'Inactive'],
                    ['Level (TINGKAT)', $user->TINGKAT ?? 'N/A'],
                    ['Department (kodeBag)', $user->kodeBag ?? 'N/A'],
                    ['Has Password', !empty($user->UID) ? 'Yes' : 'No'],
                    ['Password Length', $user->UID ? strlen($user->UID) : 0],
                    ['Password Type', $this->detectPasswordType($user->UID)],
                    ['Last IP', $user->IPAddres ?? 'N/A'],
                    ['Last Host', $user->HOSTID ?? 'N/A'],
                ]
            );

            // Test password if provided
            if ($password) {
                $this->info("Testing password authentication...");
                
                if (!$user->UID) {
                    $this->warn('No password stored for this user');
                    return;
                }

                // Try hash verification
                $hashValid = Hash::check($password, $user->UID);
                $plainValid = $user->UID === $password;
                
                if ($hashValid) {
                    $this->info('✓ Password valid (hashed)');
                } elseif ($plainValid) {
                    $this->info('✓ Password valid (plain text)');
                    $this->warn('⚠ Password is stored as plain text - should be hashed');
                } else {
                    $this->error('✗ Password invalid');
                    $this->info("Stored password preview: " . substr($user->UID, 0, 10) . "...");
                    $this->info("Input password length: " . strlen($password));
                }
            }
            
        } catch (\Exception $e) {
            $this->error('Authentication test failed: ' . $e->getMessage());
        }
    }

    private function detectPasswordType($password)
    {
        if (empty($password)) {
            return 'None';
        }
        
        if (substr($password, 0, 4) === '$2y$' || substr($password, 0, 4) === '$2a$' || substr($password, 0, 4) === '$2b$') {
            return 'Bcrypt Hash';
        }
        
        if (strlen($password) === 60 && substr($password, 0, 1) === '$') {
            return 'Likely Hash';
        }
        
        return 'Plain Text';
    }
}