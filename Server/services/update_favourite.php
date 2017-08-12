<?php
require("database-config.php");

$userId = $_POST['userId'];
$locationId = $_POST['locationId'];
$favourite = $_POST['favourite'];

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
$query = "SELECT * FROM Corelations WHERE user_id = '$userId' AND location_id = '$locationId';";

// Check if there are results
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row)) {
	$query = "INSERT INTO Corelations (corelation_id, user_id, location_id, favourite) VALUES (NULL, $userId, $locationId, $favourite);";
	$result = mysqli_query($con, $query);
	echo $result;
} else {
	$query = "UPDATE Corelations SET favourite = $favourite WHERE user_id = '$userId' AND location_id = '$locationId';";
	$result = mysqli_query($con, $query);
	echo $result;
}
 
// Close connections
mysqli_close($con);
?>