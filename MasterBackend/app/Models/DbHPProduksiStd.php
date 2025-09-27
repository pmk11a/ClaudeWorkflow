<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbHPProduksiStd extends Model
{
    use HasFactory;

    protected $table = 'dbHPProduksiStd';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeSetting', 'KodeBrg', 'KodeBom', 'RpBahan', 'RpProses', 'HPP'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbHPProduksiStdDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}