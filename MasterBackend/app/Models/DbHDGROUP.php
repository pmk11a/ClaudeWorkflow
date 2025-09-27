<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbHDGROUP extends Model
{
    use HasFactory;

    protected $table = 'DBHDGROUP';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KODEHDGRP', 'NAMAHDGRP', 'KODEGRP'
    ];

}
