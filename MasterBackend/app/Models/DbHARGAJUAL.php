<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbHARGAJUAL extends Model
{
    use HasFactory;

    protected $table = 'DBHARGAJUAL';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEBRG', 'KODEJENISCUSTSUPP', 'HARGA1', 'HARGA2'
    ];

    protected $casts = [
        'HARGA1' => 'decimal:2',
        'HARGA2' => 'decimal:2'
    ];


    // Relationships
    public function item()
    {
        return $this->belongsTo(Dbbarang::class, 'KODEBRG', 'KODEBRG');
    }

    public function details()
    {
        return $this->hasMany(DbHARGAJUALDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}