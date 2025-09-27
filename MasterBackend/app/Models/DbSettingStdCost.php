<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbSettingStdCost extends Model
{
    use HasFactory;

    protected $table = 'dbSettingStdCost';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KodeSetting', 'BerlakuMulai', 'BerlakuSampai', 'Keterangan'
    ];

}
