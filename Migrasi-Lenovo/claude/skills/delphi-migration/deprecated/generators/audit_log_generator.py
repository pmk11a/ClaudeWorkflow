#!/usr/bin/env python3
"""
Laravel AuditLog Support Generator
Generates the AuditLog support class for audit trail
"""


def generate_audit_log_class() -> str:
    """Generate the AuditLog support class"""
    return '''<?php

namespace App\\Support;

use Illuminate\\Support\\Facades\\DB;
use Illuminate\\Support\\Facades\\Log;

/**
 * AuditLog
 * 
 * Centralized audit logging service
 * 
 * Delphi equivalent: LoggingData(IDUser, Activity, Source, NoBukti, Keterangan)
 * 
 * Usage:
 *   AuditLog::log('I', 'Aktiva', '', auth()->id(), 'Created new aktiva');
 *   AuditLog::log('U', 'Aktiva', 'AK-001', auth()->id(), 'Updated aktiva');
 *   AuditLog::log('D', 'Aktiva', 'AK-001', auth()->id(), 'Deleted aktiva');
 */
class AuditLog
{
    /**
     * Activity type constants
     */
    public const INSERT = 'I';
    public const UPDATE = 'U';
    public const DELETE = 'D';
    public const AUTHORIZE = 'A';
    public const CANCEL = 'C';
    public const PRINT = 'P';
    public const EXPORT = 'E';

    /**
     * Log activity to audit trail
     * 
     * @param string $activity Activity type (I/U/D/A/C/P/E)
     * @param string $source Module/source name
     * @param string $noBukti Document number
     * @param int|null $userId User ID (defaults to authenticated user)
     * @param string $keterangan Description of the activity
     * @param array $metadata Additional metadata
     * @return bool
     */
    public static function log(
        string $activity,
        string $source,
        string $noBukti,
        ?int $userId = null,
        string $keterangan = '',
        array $metadata = []
    ): bool {
        try {
            $userId = $userId ?? auth()->id();

            DB::table('log_activity')->insert([
                'user_id' => $userId,
                'activity' => $activity,
                'source' => $source,
                'no_bukti' => $noBukti,
                'keterangan' => $keterangan,
                'metadata' => !empty($metadata) ? json_encode($metadata) : null,
                'ip_address' => request()->ip(),
                'user_agent' => request()->userAgent(),
                'created_at' => now(),
            ]);

            return true;
        } catch (\\Exception $e) {
            Log::error('AuditLog failed', [
                'error' => $e->getMessage(),
                'activity' => $activity,
                'source' => $source,
            ]);

            return false;
        }
    }

    /**
     * Log insert activity
     */
    public static function insert(string $source, string $noBukti, string $keterangan, ?int $userId = null): bool
    {
        return self::log(self::INSERT, $source, $noBukti, $userId, $keterangan);
    }

    /**
     * Log update activity
     */
    public static function update(string $source, string $noBukti, string $keterangan, ?int $userId = null): bool
    {
        return self::log(self::UPDATE, $source, $noBukti, $userId, $keterangan);
    }

    /**
     * Log delete activity
     */
    public static function delete(string $source, string $noBukti, string $keterangan, ?int $userId = null): bool
    {
        return self::log(self::DELETE, $source, $noBukti, $userId, $keterangan);
    }

    /**
     * Log authorization activity
     */
    public static function authorize(string $source, string $noBukti, string $keterangan, ?int $userId = null): bool
    {
        return self::log(self::AUTHORIZE, $source, $noBukti, $userId, $keterangan);
    }

    /**
     * Get activity history for a document
     * 
     * @param string $source Module/source name
     * @param string $noBukti Document number
     * @return \\Illuminate\\Support\\Collection
     */
    public static function getHistory(string $source, string $noBukti)
    {
        return DB::table('log_activity')
            ->where('source', $source)
            ->where('no_bukti', $noBukti)
            ->orderByDesc('created_at')
            ->get();
    }

    /**
     * Get recent activities by user
     * 
     * @param int $userId
     * @param int $limit
     * @return \\Illuminate\\Support\\Collection
     */
    public static function getByUser(int $userId, int $limit = 50)
    {
        return DB::table('log_activity')
            ->where('user_id', $userId)
            ->orderByDesc('created_at')
            ->limit($limit)
            ->get();
    }

    /**
     * Get activity description
     */
    public static function getActivityLabel(string $activity): string
    {
        return match ($activity) {
            self::INSERT => 'Insert',
            self::UPDATE => 'Update',
            self::DELETE => 'Delete',
            self::AUTHORIZE => 'Authorize',
            self::CANCEL => 'Cancel',
            self::PRINT => 'Print',
            self::EXPORT => 'Export',
            default => $activity,
        };
    }
}
'''


def generate_migration() -> str:
    """Generate the migration for log_activity table"""
    return '''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('log_activity', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->char('activity', 1)->index()->comment('I=Insert, U=Update, D=Delete, A=Authorize, C=Cancel, P=Print, E=Export');
            $table->string('source', 50)->index()->comment('Module/table name');
            $table->string('no_bukti', 50)->nullable()->index()->comment('Document number');
            $table->text('keterangan')->nullable()->comment('Activity description');
            $table->json('metadata')->nullable()->comment('Additional data');
            $table->ipAddress('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->timestamp('created_at')->useCurrent();

            // Composite index for efficient querying
            $table->index(['source', 'no_bukti']);
            $table->index(['user_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('log_activity');
    }
};
'''


if __name__ == "__main__":
    print("=== AuditLog Class ===")
    print(generate_audit_log_class())
    
    print("\n=== Migration ===")
    print(generate_migration())
