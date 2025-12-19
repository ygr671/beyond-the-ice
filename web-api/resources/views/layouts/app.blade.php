<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>@yield('title')</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #0f172a;
            color: #e5e7eb;
        }
        .card {
            background-color: #020617;
            border: 1px solid #1e293b;
        }
        pre {
            background: #020617;
            color: #e5e7eb;
            padding: 1rem;
            border-radius: .5rem;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-dark bg-dark mb-4">
    <div class="container">
        <a class="navbar-brand" href="/leaderboard">Scores</a>
        <div>
            <a class="btn btn-outline-light btn-sm me-2" href="/leaderboard">Leaderboard</a>
            <a class="btn btn-outline-light btn-sm" href="/podium">Podium</a>
        </div>
    </div>
</nav>

<div class="container">
    @yield('content')
</div>

</body>
</html>
