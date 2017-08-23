<?php
require("config.php");

$receiptId = $_POST['receiptId'];
$locationId = $_POST['locationId'];
$rating = $_POST['rating'];

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
$query = "SELECT * FROM Receipts WHERE receipt_id = '$receiptId';";

// Check if there are results
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row)) {
	$status->status = "receipt_does_not_exist";
} else {
	$query = "UPDATE Receipts SET rating = $rating WHERE receipt_id = $receiptId;";
	$result = mysqli_query($con, $query);
	if($result) {
		$query = "SELECT COUNT(rating) as noRatings, SUM(rating) as ratingsSum FROM Receipts NATURAL JOIN Offers WHERE location_id = '$locationId';";
		$result = mysqli_query($con, $query);
		$row = $result->fetch_object();
		$rating = $row->ratingsSum / $row->noRatings;

		$query = "UPDATE Locations SET rating = $rating WHERE location_id = '$locationId';";
		$result = mysqli_query($con, $query);

		if($result) {
			$status->status = "success";
		} else {
			$status->status = "locations_update_failed";
		}
	} else {
		$status->status = "receipt_update_failed";
	}
}

echo json_encode($status); 
// Close connections
mysqli_close($con);
?>