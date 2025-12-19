@extends('layouts.app')

@section('title', 'Leaderboard')

@section('content')
<h1 class="mb-4">Leaderboard</h1>

<div class="card">
    <div class="card-body">
        <table class="table table-dark table-striped">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Username</th>
                    <th>Score</th>
                    <th>Durée (s)</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($players as $i => $player)
                <tr>
                    <td>{{ $i + 1 }}</td>
                    <td>{{ $player->username }}</td>
                    <td>{{ $player->score }}</td>
                    <td>{{ $player->duration }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
