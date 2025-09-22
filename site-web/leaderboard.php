<?php 
  // Including bdd.php
  require_once("bdd.php");
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Beyond the Ice : classement</title>
</head>
<body>
    <?php
      // implement leaderboard logic there
      $check = $registered_players->execute();

      if (!$check)
      {
        echo "Aucun score n'a été enregistré.";
        exit;
      }

      foreach ($registered_players as $row)
      {
        $last_name = $row["last_name"];
        $score = $row["score"];
        echo "$last_name : $score<br>";
      }
    ?>
</body>
</html>