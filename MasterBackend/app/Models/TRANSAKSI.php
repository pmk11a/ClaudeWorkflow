<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TRANSAKSI extends Model
{
    use HasFactory;

    protected $table = 'TRANSAKSI';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'PERK', 'SUBP', 'NOBU', 'TGBU', 'BARI', 'URAI', 'JUML', 'SALD', 'SALDS', 'USR_MAINT', 'TGL_MAINT', 'Column 11', 'Column 12'
    ];

}
