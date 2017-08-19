<?php
require("config.php");
 
$receiptId = $_POST['receiptId'];

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
	echo json_encode($status);
} else {
	$query = "UPDATE Receipts SET redeemed = 1 WHERE receipt_id = $receiptId;";
	$result = mysqli_query($con, $query);
	if($result) {
		$status->status = "success";
	} else {
		$status->status = "error";
	}
	echo json_encode($status);
}
 
// Close connections
mysqli_close($con);
?>