<?php
session_start();

require("services/database-config.php");

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$query = "SHOW TABLES LIKE 'Categories';";
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row)) {
  $query = "SELECT *, false AS has_categories FROM System;";
} else {
  $query = "SELECT *, true AS has_categories FROM System;";
}

$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row)) {
  header('location:error.php');
} else {
  $_SESSION['type'] = $row->type;
  $_SESSION['main_colour'] = $row->main_colour;
  $_SESSION['opaque_colour'] = $row->opaque_colour;
  $_SESSION['background_colour'] = $row->background_colour;
  $_SESSION['cell_background_colour'] = $row->cell_background_colour;
  $_SESSION['main_logo'] = $row->main_logo;
  $_SESSION['main_title'] = $row->main_title;
  $_SESSION['main_tab_logo'] = $row->main_tab_logo;
  $_SESSION['main_tab_title'] = $row->main_tab_title;
  $_SESSION['navigation_logo'] = $row->navigation_logo;

  if (strcmp($row->type, "location")) {
    $_SESSION['has_credit'] = false;
  } else {
    $_SESSION['has_credit'] = true;
  }

  if ($row->has_categories == "1") {
    $query = "SELECT * FROM Categories";
    if ($result = mysqli_query($con, $query)) {
      $resultArray = array();
      $tempArray = array();
     
      while($row = $result->fetch_object()) {
        $tempArray = $row;
        array_push($resultArray, $tempArray);
      }
     
      $_SESSION['categories'] = $resultArray;
      $_SESSION['has_categories'] = true;
    } else {
      $_SESSION['has_categories'] = false;
    }
  } else {
    $_SESSION['has_categories'] = false;
  }

  if (isset($_SESSION['logged_in'])) {
    if ($_SESSION['logged_in'] != "false") {
      header('location:offers.php');
    } else {
      header('location:login.php');
    }
  } else {
    header('location:login.php');
  }
}

// Close connections
mysqli_close($con);
?>