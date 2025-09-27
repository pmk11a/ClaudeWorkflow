<?php

namespace App\Http\Controllers;

use App\Models\DbFLPASS;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DiagnosticController extends Controller
{
    public function index()
    {
        $diagnostics = $this->runDiagnostics();
        return view('diagnostics.index', compact('diagnostics'));
    }

    public function api()
    {
        $diagnostics = $this->runDiagnostics();
        return response()->json($diagnostics);
    }

    private function runDiagnostics()
    {
        $results = [
            'timestamp' => now()->toISOString(),
            'environment' => app()->environment(),
            'database' => $this->testDatabaseConnection(),
            'users' => $this->getUserStats(),
            'configuration' => $this->getConfiguration()
        ];

        return $results;
    }

    private function testDatabaseConnection()
    {
        try {
            $pdo = DB::connection()->getPdo();
            
            return [
                'status' => 'connected',
                'driver' => $pdo->getAttribute(\PDO::ATTR_DRIVER_NAME),
                'server_info' => $pdo->getAttribute(\PDO::ATTR_SERVER_INFO),
                'server_version' => $pdo->getAttribute(\PDO::ATTR_SERVER_VERSION),
                'connection_status' => $pdo->getAttribute(\PDO::ATTR_CONNECTION_STATUS),
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'failed',
                'error' => $e->getMessage(),
                'error_code' => $e->getCode(),
            ];
        }
    }

    private function getUserStats()
    {
        try {
            $totalUsers = DbFLPASS::count();
            $activeUsers = DbFLPASS::where('STATUS', 1)->count();
            $usersWithPasswords = DbFLPASS::whereNotNull('UID')->where('UID', '!=', '')->count();
            
            // Sample users for testing
            $sampleUsers = DbFLPASS::where('STATUS', 1)
                ->select('USERID', 'FullName', 'STATUS', 'TINGKAT')
                ->take(5)
                ->get()
                ->map(function ($user) {
                    return [
                        'userid' => $user->USERID,
                        'name' => $user->FullName,
                        'status' => $user->STATUS,
                        'level' => $user->TINGKAT,
                        'has_password' => !empty($user->UID)
                    ];
                });

            return [
                'status' => 'success',
                'total_users' => $totalUsers,
                'active_users' => $activeUsers,
                'users_with_passwords' => $usersWithPasswords,
                'sample_users' => $sampleUsers
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'failed',
                'error' => $e->getMessage()
            ];
        }
    }

    private function getConfiguration()
    {
        $config = config('database.connections.sqlsrv');
        
        return [
            'host' => $config['host'],
            'port' => $config['port'],
            'database' => $config['database'],
            'username' => $config['username'],
            'encrypt' => $config['encrypt'],
            'trust_server_certificate' => $config['trust_server_certificate'],
            'multiple_active_result_sets' => $config['multiple_active_result_sets'] ?? null,
            'timeout' => $config['options'][\PDO::ATTR_TIMEOUT] ?? null,
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
        ];
    }

    public function testUser(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'nullable|string'
        ]);

        $username = strtoupper($request->username);
        
        try {
            $user = DbFLPASS::where('USERID', $username)->first();
            
            if (!$user) {
                return response()->json([
                    'status' => 'not_found',
                    'message' => 'User not found'
                ]);
            }

            $result = [
                'status' => 'found',
                'user' => [
                    'userid' => $user->USERID,
                    'name' => $user->FullName,
                    'status' => $user->STATUS,
                    'active' => (bool) $user->STATUS,
                    'level' => $user->TINGKAT,
                    'department' => $user->kodeBag,
                    'has_password' => !empty($user->UID2),
                    'password_length' => $user->UID2 ? strlen($user->UID2) : 0,
                    'password_type' => $this->detectPasswordType($user->UID2),
                    'last_ip' => $user->IPAddres,
                    'last_host' => $user->HOSTID,
                ]
            ];

            // Test password if provided
            if ($request->password && $user->UID2) {
                $hashValid = Hash::check($request->password, $user->UID2);
                $plainValid = $user->UID2 === $request->password;
                
                $result['password_test'] = [
                    'hash_valid' => $hashValid,
                    'plain_valid' => $plainValid,
                    'overall_valid' => $hashValid || $plainValid,
                    'method' => $hashValid ? 'hash' : ($plainValid ? 'plain' : 'none')
                ];
            }

            return response()->json($result);
            
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    private function detectPasswordType($password)
    {
        if (empty($password)) {
            return 'none';
        }
        
        if (substr($password, 0, 4) === '$2y$' || substr($password, 0, 4) === '$2a$' || substr($password, 0, 4) === '$2b$') {
            return 'bcrypt';
        }
        
        if (strlen($password) === 60 && substr($password, 0, 1) === '$') {
            return 'hash';
        }
        
        return 'plain';
    }
}