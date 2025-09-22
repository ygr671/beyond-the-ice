<?php
  // Check request method
  if ($_SERVER["REQUEST_METHOD"] != "POST")
  {
    http_response_code(405); // Method not allowed response code
    echo json_encode(["error" => "Invalid method"]);
    exit;
  }

  // Including bdd.php
  require_once("../bdd.php");

  // Response type
  header('Content-Type: application/json');

  // Get request data
  $raw = file_get_contents("php://input");

  // Decode request data
  $data = json_decode($raw, true);

  if (json_last_error() != JSON_ERROR_NONE)
  {
    http_response_code(400);
    echo json_encode(["error" => "Invalid JSON"]);
    exit;
  }

  $last_name = $data["last_name"];
  $score = (int)$data["score"];

  // Check if types are both string and integer and is they're not empty
  if (
    !isset($data["last_name"], $data["score"]) ||
    empty($data["last_name"]) ||
    !is_string($data["last_name"]) ||
    !is_int($data["score"]))
  {
    http_response_code(400);
    echo json_encode(["error" => "Invalid Data"]);
    exit;
  }


  // check if received last name isn't already in the database
  $present = false;
  $check = $presence_check->bindValue(":last_name", $last_name, PDO::PARAM_STR);
  $presence_check->execute();

  $present = $presence_check->fetchColumn() > 0;

  if (!$present)
  {
    $check1 = $register_player->bindValue(":last_name", $last_name, PDO::PARAM_STR);
    $check1 &= $register_player->bindValue(":score", $score, PDO::PARAM_INT); // Stylish way to check if previous binding failed or not
    
    /* TODO : add checks for both executes there */
    $register_player->execute();

    http_response_code(200);
    echo json_encode(["success" => "Player successfully registered"]);
  }
  else
  {
    $check1 = $update_player->bindValue(":score", $score, PDO::PARAM_INT);
    $check &= $update_player->bindValue(":last_name", $last_name, PDO::PARAM_STR);
    
    /* TODO : add checks for both executes there */
    $update_player->execute();

    http_response_code(200);
    echo json_encode(["success" => "Player score successfully updated"]);
  }


?>