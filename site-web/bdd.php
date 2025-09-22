<?php
  $db_filename = "db.sqlite";

  $SQL_DSN = "sqlite:/home/yzd/Documents/BUT/s3/t3/beyond-the-ice/site-web/api/$db_filename";

  try
  {
    $pdo = new PDO($SQL_DSN);
  }
  catch (PDOException $e)
  {
    echo "Erreur".$e->getMessage();
    exit;
  }

  // fetch the registered users and their score
  $registered_players = $pdo->prepare("SELECT * FROM players");

  // check if player is already in the database
  $presence_check = $pdo->prepare("SELECT COUNT(last_name) FROM players WHERE last_name = :last_name");

  // register player
  $register_player = $pdo->prepare("INSERT INTO players (last_name, score) VALUES (:last_name, :score)");

  // update player's score
  $update_player = $pdo->prepare("UPDATE players SET score = :score WHERE last_name = :last_name");

  /* TODO : implémenter la gestion du leaderboard avec PDO + SQLite */
?>