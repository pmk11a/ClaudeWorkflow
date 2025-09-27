<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MSUP extends Model
{
    use HasFactory;

    protected $table = 'MSUP';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'CSYM', 'CSCU', 'CSTC', 'CSMZ', 'CSCD', 'CSNM', 'CSLN', 'CSWP', 'CSPK', 'CSA1', 'CSA2', 'CSA3', 'CSA4', 'CSTP', 'CSFX', 'CSTL', 'CSMD', 'CSDS', 'CSPF', 'CSBR', 'CSBB', 'CSCB', 'CSPB', 'CSCR', 'CSDB', 'CSRT', 'CSYS', 'CSID', 'CSTM', 'CSBC', 'CSCC', 'CSNC'
    ];

    protected $casts = [
        'CSMD' => 'decimal:2',
        'CSDS' => 'decimal:2',
        'CSPF' => 'decimal:2',
        'CSBR' => 'decimal:2',
        'CSBB' => 'decimal:2',
        'CSCB' => 'decimal:2',
        'CSPB' => 'decimal:2',
        'CSCR' => 'decimal:2',
        'CSDB' => 'decimal:2',
        'CSRT' => 'decimal:2',
        'CSYS' => 'decimal:2',
    ];

}
