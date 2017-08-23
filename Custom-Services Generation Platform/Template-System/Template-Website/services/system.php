<?php
require("config.php");

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
	$system->error = "error";
} else {
	echo json_encode($row);
}

// Close connections
mysqli_close($con);
?>