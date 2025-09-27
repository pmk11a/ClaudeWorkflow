<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sysdiagrams extends Model
{
    use HasFactory;

    protected $table = 'sysdiagrams';
    protected $primaryKey = 'diagram_id';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'name', 'principal_id', 'diagram_id', 'version', 'definition'
    ];

}
