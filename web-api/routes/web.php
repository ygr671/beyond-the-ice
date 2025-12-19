<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PlayerController;

/*
Route::prefix('admin')->group(function () {
    Route::get('clear', [AdminController::class, 'clearGames']);
    Route::get('users', [AdminController::class, 'users']);
});
*/

use App\Http\Controllers\PlayerViewController;

Route::get('/', fn () => redirect('/leaderboard'));

Route::get('/leaderboard', [PlayerViewController::class, 'leaderboard']);
Route::get('/podium', [PlayerViewController::class, 'podium']);
