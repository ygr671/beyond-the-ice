<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PlayerController;

Route::get('/', function () {
    return response()->json([
        'message' => "Vous n'avez rien à faire ici :)"
    ]);
});

Route::get('players/ranking', [PlayerController::class, 'ranking']);
Route::get('players/podium', [PlayerController::class, 'podium']);

Route::apiResource('players', PlayerController::class);
