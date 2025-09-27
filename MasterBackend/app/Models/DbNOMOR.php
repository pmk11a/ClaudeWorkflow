<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DbNOMOR extends Model
{
    use HasFactory;

    protected $table = 'DBNOMOR';
    protected $primaryKey = '';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'BKK', 'NOBKK', 'BKM', 'NOBKM', 'BBM', 'NOBBM', 'BBK', 'NOBBK', 'BMM', 'NOBMM', 'BJK', 'NOBJK', 'PJL', 'NoPJL', 'PBL', 'NOPBL', 'BPPB', 'NOBPPB', 'BPSB', 'NOBPSB', 'BBP', 'NOBBP', 'BPB', 'NOBPB', 'SPRK', 'NOSPRK', 'BSPRK', 'NOBSPRK', 'PPL', 'NOPPL', 'BPL', 'NOBPL', 'PO', 'NOPO', 'BPO', 'NOBPO', 'BP', 'NOBP', 'BPSPRK', 'NOBPSPRK', 'INS', 'NOINS', 'KNS', 'NOKNS', 'RPB', 'NORPB', 'SPG', 'NOSPG', 'OPN', 'NOOPN', 'KMS', 'NOKMS', 'RBPB', 'NORBPB', 'ENQ', 'NOENQ', 'CR', 'NOCR', 'SO', 'NOSO', 'RKL', 'NORKL', 'SC', 'NOSC', 'SPP', 'NOSPP', 'SPB', 'NOSPB', 'RSPB', 'NORSPB', 'INV', 'NOINV', 'PNJ', 'NOPNJ', 'TRC', 'NOTRC', 'SHIP', 'NOSHIP', 'TBJ', 'NOTBJ', 'RBJ', 'NORBJ', 'TRS', 'NOTRS', 'AKM', 'RPJ', 'NORPJ', 'BHN', 'NOBHN', 'ALIAS', 'PEMISAH', 'FORMAT1', 'FORMAT2', 'FORMAT3', 'FORMAT4', 'Contoh', 'Reset', 'NOSERI', 'INICAB', 'DigitNomor', 'SPK', 'RBP', 'PR', 'DN', 'OPBJ', 'KMBJ', 'INVC', 'NoINVC', 'SPR', 'NoSPR', 'KN', 'NoKN', 'HPD', 'PBS', 'RPBS', 'POS', 'HT', 'PT', 'TT', 'KRS', 'AVT'
    ];

}
