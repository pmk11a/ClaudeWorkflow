<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\DbFLPASS;
use App\Services\UserPermissionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    protected $permissionService;

    public function __construct(UserPermissionService $permissionService)
    {
        $this->permissionService = $permissionService;
    }

    /**
     * Display a listing of users
     */
    public function index(Request $request)
    {
        $query = DbFLPASS::query();

        // Search functionality
        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('USERID', 'like', "%{$search}%")
                  ->orWhere('FullName', 'like', "%{$search}%")
                  ->orWhere('kodeBag', 'like', "%{$search}%");
            });
        }

        // Filter by status
        if ($request->has('status') && $request->status !== '') {
            $query->where('STATUS', $request->status);
        }

        // Filter by tingkat (user level)
        if ($request->has('tingkat') && $request->tingkat !== '') {
            $query->where('TINGKAT', $request->tingkat);
        }

        $users = $query->orderBy('USERID')->paginate(20);

        // Add permission summary for each user
        foreach ($users as $user) {
            $user->permission_summary = $this->permissionService->getUserPermissionSummary($user->USERID);
        }

        return view('users.index', compact('users'));
    }

    /**
     * Show the form for creating a new user
     */
    public function create()
    {
        return view('users.create');
    }

    /**
     * Store a newly created user
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'USERID' => 'required|string|max:20|unique:DBFLPASS,USERID',
            'FullName' => 'required|string|max:100',
            'TINGKAT' => 'required|integer|min:1|max:5',
            'STATUS' => 'boolean',
            'kodeBag' => 'nullable|string|max:10',
            'KodeJab' => 'nullable|string|max:10',
            'password' => 'required|string|min:6',
            'set_default_permissions' => 'boolean'
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        try {
            // Create user
            $user = new DbFLPASS();
            $user->USERID = strtoupper($request->USERID);
            $user->FullName = $request->FullName;
            $user->TINGKAT = $request->TINGKAT;
            $user->STATUS = $request->has('STATUS') ? 1 : 0;
            $user->kodeBag = $request->kodeBag;
            $user->KodeJab = $request->KodeJab;
            
            // Hash password (assuming UID field is used for password)
            $user->UID = Hash::make($request->password);
            
            $user->save();

            // Set default permissions if requested
            if ($request->has('set_default_permissions')) {
                $this->permissionService->setDefaultPermissions($user->USERID, $user->TINGKAT);
            }

            return redirect()->route('users.index')
                ->with('success', 'User created successfully!');

        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'Failed to create user: ' . $e->getMessage())
                ->withInput();
        }
    }

    /**
     * Display the specified user
     */
    public function show($userId)
    {
        $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
        $permissionHierarchy = $this->permissionService->getUserMenuHierarchy($userId);
        $permissionSummary = $this->permissionService->getUserPermissionSummary($userId);

        return view('users.show', compact('user', 'permissionHierarchy', 'permissionSummary'));
    }

    /**
     * Show the form for editing the specified user
     */
    public function edit($userId)
    {
        $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
        return view('users.edit', compact('user'));
    }

    /**
     * Update the specified user
     */
    public function update(Request $request, $userId)
    {
        $user = DbFLPASS::where('USERID', $userId)->firstOrFail();

        $validator = Validator::make($request->all(), [
            'FullName' => 'required|string|max:100',
            'TINGKAT' => 'required|integer|min:1|max:5',
            'STATUS' => 'boolean',
            'kodeBag' => 'nullable|string|max:10',
            'KodeJab' => 'nullable|string|max:10',
            'password' => 'nullable|string|min:6'
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        try {
            $user->FullName = $request->FullName;
            $user->TINGKAT = $request->TINGKAT;
            $user->STATUS = $request->has('STATUS') ? 1 : 0;
            $user->kodeBag = $request->kodeBag;
            $user->KodeJab = $request->KodeJab;

            // Update password if provided
            if ($request->password) {
                $user->UID = Hash::make($request->password);
            }

            $user->save();

            return redirect()->route('users.index')
                ->with('success', 'User updated successfully!');

        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'Failed to update user: ' . $e->getMessage())
                ->withInput();
        }
    }

    /**
     * Remove the specified user
     */
    public function destroy($userId)
    {
        try {
            $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
            
            // Delete user permissions first
            \App\Models\DbFLMENU::where('USERID', $userId)->delete();
            
            // Delete user
            $user->delete();

            return redirect()->route('users.index')
                ->with('success', 'User deleted successfully!');

        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'Failed to delete user: ' . $e->getMessage());
        }
    }

    /**
     * Toggle user status (active/inactive)
     */
    public function toggleStatus($userId)
    {
        try {
            $user = DbFLPASS::where('USERID', $userId)->firstOrFail();
            $user->STATUS = $user->STATUS ? 0 : 1;
            $user->save();

            $status = $user->STATUS ? 'activated' : 'deactivated';
            
            return response()->json([
                'success' => true,
                'message' => "User {$status} successfully!",
                'status' => $user->STATUS
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update user status: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Copy permissions from one user to another
     */
    public function copyPermissions(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'from_user' => 'required|string|exists:DBFLPASS,USERID',
            'to_user' => 'required|string|exists:DBFLPASS,USERID'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid user selection'
            ], 400);
        }

        try {
            $success = $this->permissionService->copyUserPermissions(
                $request->from_user, 
                $request->to_user
            );

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'Permissions copied successfully!'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to copy permissions'
                ], 500);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get users for select dropdown (AJAX)
     */
    public function getUsersForSelect(Request $request)
    {
        $search = $request->get('search', '');
        
        $users = DbFLPASS::select('USERID', 'FullName')
            ->where('STATUS', 1)
            ->when($search, function($query, $search) {
                $query->where(function($q) use ($search) {
                    $q->where('USERID', 'like', "%{$search}%")
                      ->orWhere('FullName', 'like', "%{$search}%");
                });
            })
            ->orderBy('USERID')
            ->limit(20)
            ->get();

        return response()->json([
            'users' => $users->map(function($user) {
                return [
                    'id' => $user->USERID,
                    'text' => "{$user->USERID} - {$user->FullName}"
                ];
            })
        ]);
    }

    /**
     * Export users to CSV
     */
    public function export(Request $request)
    {
        $query = DbFLPASS::query();

        // Apply same filters as index
        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('USERID', 'like', "%{$search}%")
                  ->orWhere('FullName', 'like', "%{$search}%");
            });
        }

        if ($request->has('status') && $request->status !== '') {
            $query->where('STATUS', $request->status);
        }

        if ($request->has('tingkat') && $request->tingkat !== '') {
            $query->where('TINGKAT', $request->tingkat);
        }

        $users = $query->orderBy('USERID')->get();

        $filename = 'users_export_' . date('Y-m-d_H-i-s') . '.csv';
        
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ];

        $callback = function() use ($users) {
            $file = fopen('php://output', 'w');
            
            // CSV Header
            fputcsv($file, [
                'User ID',
                'Full Name', 
                'Level',
                'Status',
                'Department Code',
                'Job Code',
                'Host ID',
                'IP Address'
            ]);

            // CSV Data
            foreach ($users as $user) {
                fputcsv($file, [
                    $user->USERID,
                    $user->FullName,
                    $user->TINGKAT,
                    $user->STATUS ? 'Active' : 'Inactive',
                    $user->kodeBag,
                    $user->KodeJab,
                    $user->HOSTID,
                    $user->IPAddres
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}