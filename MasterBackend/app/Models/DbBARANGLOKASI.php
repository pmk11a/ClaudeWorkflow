<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBARANGLOKASI extends Model
{
    use HasFactory;

    protected $table = 'DBBARANGLOKASI';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeGdg', 'Lokasi', 'KodeBrg'
    ];



    // Relationships
    public function details()
    {
        return $this->hasMany(DbBARANGLOKASIDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}