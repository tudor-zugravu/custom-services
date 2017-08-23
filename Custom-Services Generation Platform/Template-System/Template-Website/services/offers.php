<?php
require("config.php");

$userId = $_POST['userId'];
$hasCategories = $_POST['hasCategories'];

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

if($hasCategories == "true") {
	$query = "SELECT *, COALESCE((SELECT favourite from Corelations cor WHERE cor.location_id = loc.location_id and cor.user_id = '$userId'), 0) as favourite
			FROM Offers
			NATURAL JOIN Locations loc
			NATURAL JOIN Vendors
			NATURAL JOIN Categories;";
} else {
	$query = "SELECT *, COALESCE((SELECT favourite from Corelations cor WHERE cor.location_id = loc.location_id and cor.user_id = '$userId'), 0) as favourite
			FROM Offers
			NATURAL JOIN Locations loc
			NATURAL JOIN Vendors;";
}
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