<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\HasApiTokens;

class DbFLPASS extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'DBFLPASS';
    protected $primaryKey = 'USERID';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'USERID', 'UID', 'UID2', 'FullName', 'TINGKAT', 'STATUS', 'HOSTID', 'IPAddres', 'kodeBag', 'KodeJab', 'KodeKasir', 'Kodegdg', 'keynik'
    ];

    protected $hidden = [
        'UID', 'keynik'
    ];

    protected $casts = [
        'STATUS' => 'boolean',
        'TINGKAT' => 'integer'
    ];

    // Authentication methods
    public function getAuthIdentifierName()
    {
        return 'USERID';
    }

    public function getAuthIdentifier()
    {
        return $this->USERID;
    }

    public function getAuthPassword()
    {
        return $this->UID2;
    }

    public function getRememberToken()
    {
        return null;
    }

    public function setRememberToken($value)
    {
        // Not implemented
    }

    public function getRememberTokenName()
    {
        return null;
    }

    // Custom authentication methods
    public function validatePassword($password)
    {
        // Check if UID2 is base64 encoded
        $decodedUID2 = base64_decode($this->UID2, true);
        if ($decodedUID2 !== false) {
            // Try direct comparison with decoded value
            if ($decodedUID2 === $password) {
                return true;
            }
        }
        
        // Try hashed password check
        return Hash::check($password, $this->UID2);
    }

    public function setPassword($password)
    {
        $this->UID2 = Hash::make($password);
    }

    // User level methods
    public function isSuperAdmin()
    {
        return $this->TINGKAT >= 5;
    }

    public function isManager()
    {
        return $this->TINGKAT >= 3;
    }

    public function isActive()
    {
        return (bool) $this->STATUS;
    }

    public function getUserLevelName()
    {
        switch ($this->TINGKAT) {
            case 5: return 'Super Admin';
            case 4: return 'Admin';
            case 3: return 'Manager';
            case 2: return 'Supervisor';
            case 1: return 'User';
            default: return 'Unknown';
        }
    }

    // Relationships
    public function menuPermissions()
    {
        return $this->hasMany(DbFLMENU::class, 'USERID', 'USERID');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('STATUS', 1);
    }

    public function scopeByLevel($query, $level)
    {
        return $query->where('TINGKAT', $level);
    }

    public function scopeByDepartment($query, $deptCode)
    {
        return $query->where('kodeBag', $deptCode);
    }

    // Accessor for display name
    public function getDisplayNameAttribute()
    {
        return "{$this->USERID} - {$this->FullName}";
    }

    // Override save to protect SA status
    public function save(array $options = [])
    {
        // Protect SA user status from being changed to 0
        if ($this->USERID === 'SA' && $this->isDirty('STATUS') && $this->STATUS == 0) {
            \Log::warning('Prevented SA status from being changed to 0', [
                'original_status' => $this->getOriginal('STATUS'),
                'new_status' => $this->STATUS,
                'dirty_attributes' => $this->getDirty(),
                'trace' => debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 5)
            ]);
            $this->STATUS = 1; // Force to active
        }
        
        return parent::save($options);
    }

    // Check if user has specific menu permission
    public function hasMenuPermission($menuCode, $permission = 'access')
    {
        $menuPermission = $this->menuPermissions()
            ->where('L1', $menuCode)
            ->first();

        if (!$menuPermission) {
            return false;
        }

        switch ($permission) {
            case 'access':
                return (bool) $menuPermission->HASACCESS;
            case 'add':
            case 'create':
                return (bool) $menuPermission->ISTAMBAH;
            case 'edit':
            case 'update':
                return (bool) $menuPermission->ISKOREKSI;
            case 'delete':
                return (bool) $menuPermission->ISHAPUS;
            case 'print':
                return (bool) $menuPermission->ISCETAK;
            case 'export':
                return (bool) $menuPermission->ISEXPORT;
            default:
                return false;
        }
    }

    // Get user's accessible menus
    public function getAccessibleMenus()
    {
        return $this->menuPermissions()
            ->where('HASACCESS', 1)
            ->with('menu')
            ->get();
    }

    /**
     * Convert user to API array format
     */
    public function toApiArray(): array
    {
        return [
            'USERID' => $this->USERID,
            'FullName' => $this->FullName,
            'TINGKAT' => $this->TINGKAT,
            'STATUS' => $this->STATUS,
            'kodeBag' => $this->kodeBag,
            'KodeJab' => $this->KodeJab,
            'user_level_name' => $this->getUserLevelName(),
            'is_active' => $this->isActive(),
            'is_admin' => $this->TINGKAT >= 4,
            'is_manager' => $this->isManager(),
            'last_login_at' => $this->last_login_at,
            'login_count' => $this->login_count ?? 0,
        ];
    }
}