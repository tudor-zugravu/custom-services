<?php
require("config.php");

$userId = $_POST['userId'];
$locationId = $_POST['locationId'];
$rating = $_POST['rating'];

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
$query = "SELECT * FROM Ratings WHERE user_id = '$userId' AND location_id = '$locationId';";

// Check if there are results
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row)) {
	$query = "INSERT INTO Ratings (rating_id, user_id, location_id, rating) VALUES (NULL, $userId, $locationId, $rating);";
	$result = mysqli_query($con, $query);
} else {
	$query = "UPDATE Ratings SET rating = $rating WHERE user_id = '$userId' AND location_id = '$locationId';";
	$result = mysqli_query($con, $query);
}

if($result) {
	$query = "SELECT COUNT(*) as noRatings, SUM(rating) as ratingsSum FROM Ratings WHERE location_id = '$locationId';";
	$result = mysqli_query($con, $query);
	$row = $result->fetch_object();
	$rating = $row->ratingsSum / $row->noRatings;

	$query = "UPDATE Locations SET rating = $rating WHERE location_id = '$locationId';";
	$result = mysqli_query($con, $query);
	echo json_encode($result); 
} else {
	echo json_encode($result);
}

// Close connections
mysqli_close($con);
?>