<?php
  // Check request method
  if ($_SERVER["REQUEST_METHOD"] != "POST")
  {
    header("Location: error.html");
    exit;
  }

  // Including bdd.php
  require_once("bdd.php");

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

  

  /*
  // Login and password emptiness check
  if (empty($_POST["ndf"]) || empty($_POST["score"]))
  {
      exit;
  }
  */
    
  $ndf = $_POST["ndf"];
  $score = (int)$_POST["score"];
?>