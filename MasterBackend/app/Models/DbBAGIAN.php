<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbBAGIAN extends Model
{
    use HasFactory;

    protected $table = 'DBBAGIAN';
    protected $primaryKey = 'KodeBag';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeBag', 'NamaBag', 'Perkiraan', 'Biaya', 'BiayaJasaKom', 'BiayaJasaAlat', 'MyID'
    ];

    protected $casts = [
        'MyID' => 'datetime'
    ];


    // Relationships
    public function details()
    {
        return $this->hasMany(DbBAGIANDET::class, 'NOBUKTI', 'NOBUKTI');
    }

}