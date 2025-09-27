<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTarifTenaker extends Model
{
    use HasFactory;

    protected $table = 'DBTarifTenaker';
    protected $primaryKey = 'KodeTarifTenaker';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeTarifTenaker', 'Ket', 'Tarif'
    ];

    protected $casts = [
        'Tarif' => 'decimal:2',
    ];

}
