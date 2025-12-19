@extends('layouts.app')

@section('title', 'Podium')

@section('content')
<h1 class="mb-4">🏆 Podium</h1>

<div class="row g-4">
@foreach ($players as $i => $player)
    <div class="col-md-4">
        <div class="card text-center">
            <div class="card-body">
                <h2>{{ ['🥇','🥈','🥉'][$i] }}</h2>
                <h4>{{ $player->username }}</h4>
                <p>Score : <strong>{{ $player->score }}</strong></p>
                <p>Durée : {{ $player->duration }} s</p>
            </div>
        </div>
    </div>
@endforeach
</div>

@endsection
