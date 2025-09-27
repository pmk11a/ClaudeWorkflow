<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TransferData extends Model
{
    use HasFactory;

    protected $table = 'TransferData';
    protected $primaryKey = 'KeyUrut';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'KeyUrut', 'NamaTabel', 'KeyField', 'SelectTabel', 'IsTransfer', 'PrimaryKey'
    ];

}
