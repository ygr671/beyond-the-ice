<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Admin extends Model
{
    //
    protected $fillable = ['id', 'username', 'password'];
    protected $table = 'admins';
    protected $primaryKey = 'id';
    protected $keyType = 'bigIncrements';
}
