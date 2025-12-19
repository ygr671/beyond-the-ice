<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\View\View;

class PlayerViewController extends Controller
{
    public function leaderboard(): View
    {
        $players = Player::orderByDesc('score')
            ->orderByDesc('duration')
            ->get();

        return view('leaderboard', compact('players'));
    }

    public function podium(): View
    {
        $players = Player::orderByDesc('score')
            ->orderByDesc('duration')
            ->limit(3)
            ->get();

        return view('podium', compact('players'));
    }
}