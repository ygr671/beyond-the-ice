<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Player extends Model
{
    //
    protected $fillable = ['username', 'score', 'duration'];
    protected $table = 'players';
    protected $primaryKey = 'id';
    protected $keyType = 'integer';
}
