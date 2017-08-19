<?php
require("config.php");

$userId = $_POST['userId'];

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$query = "SELECT rcp.*, off.*, loc.starting_time, loc.ending_time, loc.vendor_id, vnd.name, vnd.logo_image, (SELECT favourite FROM Corelations WHERE location_id = off.location_id AND user_id = $userId) as favourite
			FROM Receipts rcp
			NATURAL JOIN Offers off 
			JOIN Locations loc ON loc.location_id = off.location_id
			JOIN Vendors vnd ON vnd.vendor_id = loc.vendor_id
			WHERE rcp.user_id = $userId;";

// Check if there are results
if ($result = mysqli_query($con, $query)) {
	// If so, then create a results array and a temporary one
	// to hold the data
	$resultArray = array();
	$tempArray = array();
 
	// Loop through each row in the result set
	while($row = $result->fetch_object()) {
		// Add each row into our results array
		$tempArray = $row;
	    array_push($resultArray, $tempArray);
	}
 
	// Finally, encode the array to JSON and output the results
	echo json_encode($resultArray);
}
 
// Close connections
mysqli_close($con);
?>