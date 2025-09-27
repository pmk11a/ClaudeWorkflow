<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbTUJUANTRANSFER extends Model
{
    use HasFactory;

    protected $table = 'DBTUJUANTRANSFER';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'IDTUJUAN', 'NAMATUJUAN', 'CONNSTR', 'SIMBOLTUJUAN'
    ];

}
