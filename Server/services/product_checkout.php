<?php
require("database-config.php");

$userId = $_POST['userId'];
$offerId = $_POST['offerId'];

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$query = "SELECT * FROM Offers WHERE offer_id = '$offerId';";

// Check if there are results
$result = mysqli_query($con, $query);
$row = $result->fetch_object();

if (is_null($row)) {
	$status->status = "offer_expired";
} else if($row->quantity == 0) {
	$status->status = "offer_expired";
} else {
	$quantity = $row->quantity - 1;
	$price = $row->discount;

	$query = "SELECT * FROM Users WHERE user_id = '$userId';";
	// Check if there are results
	$result = mysqli_query($con, $query);
	$row = $result->fetch_object();
	// Check if there are results
	if (is_null($row)) {
		$status->status = "user_does_not_exist";
	} else {
		if($row->credit >= $price) {
			$credit = $row->credit - $price;
			$query = "UPDATE Users SET credit = $credit WHERE user_id = '$userId';";
			$result = mysqli_query($con, $query);

			if($result) {
				$query = "UPDATE Offers SET quantity = $quantity WHERE offer_id = '$offerId';";
				$result = mysqli_query($con, $query);

				if($result) {
					$query = "INSERT INTO Receipts (receipt_id, offer_id, user_id, amount, rating, redeemed, purchase_date) VALUES (NULL, $offerId, $userId, $price, NULL, 0, CURRENT_TIMESTAMP);";
					$result = mysqli_query($con, $query);

					if($result) {
						$status->status = "success";
					} else {
						$status->status = "no_receipt";
					}
				} else {
					$status->status = "same_quantity";
				}
			} else {
				$status->status = "not_credited";
			}
		} else {
			$status->status = "insufficient_credit";
		}
	}
}

echo json_encode($status);

// Close connections
mysqli_close($con);
?>