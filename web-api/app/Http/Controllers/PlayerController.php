<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PlayerController extends Controller
{
    // GET /players
    public function index(): JsonResponse
    {
        return response()->json(Player::latest()->get());
    }

    // POST /players
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username' => 'required|string|max:255',
            'score' => 'required|integer',
            'duration' => 'required|integer|min:0|max:32767', // en secondes
        ]);

        $player = Player::create($validated);

        return response()->json($player, 201); // 201 Created
    }

    // GET /players/{player}
    public function show(Player $player): JsonResponse
    {
        return response()->json($player);
    }

    // PUT/PATCH /players/{player}
    public function update(Request $request, Player $player): JsonResponse
    {
        $validated = $request->validate([
            'username' => 'sometimes|string|max:255',
            'score' => 'sometimes|integer',
            'duration' => 'sometimes|integer',
        ]);

        $player->update($validated);

        return response()->json($player);
    }

    // DELETE /players/{player}
    public function destroy(Player $player): JsonResponse
    {
        $player->delete();

        return response()->json(null, 204); // 204 No Content
    }

    public function ranking(): JsonResponse
    {
        return response()->json(
            Player::orderByDesc('score')->orderByDesc('duration')->get()
        );
    }

    public function podium(): JsonResponse
    {
        return response()->json(
            Player::orderByDesc('score')->orderByDesc('duration')->limit(3)->get()
        );
    }

}