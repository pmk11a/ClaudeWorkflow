<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbHPPProduksi extends Model
{
    use HasFactory;

    protected $table = 'dbHPPProduksi';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'Tahun', 'Bulan', 'KodeBrg', 'HPPBrg'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbHPPProduksiDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}