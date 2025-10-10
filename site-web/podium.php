<?php 
  // Including bdd.php
  require_once("bdd.php");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beyond the Ice : Podium</title>
</head>
<body>
    <?php
      // implement leaderboard logic there
      $check = $podium_players->execute();

      if (!$check)
      {
        echo "Aucun score n'a été enregistré.";
        exit;
      }

      foreach ($podium_players as $row)
      {
        $last_name = $row["last_name"];
        $score = $row["score"];
        echo "<b>$last_name</b> : <b>$score</b><br>";
      }
    ?>
</body>
</html>