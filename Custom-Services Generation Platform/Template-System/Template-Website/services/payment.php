<?php
require("config.php");
require_once('../libraries/braintree-php-3.23.1/lib/Braintree.php');

Braintree_Configuration::environment('sandbox');
Braintree_Configuration::merchantId('9579dnmk65pnbf2z');
Braintree_Configuration::publicKey('8ypkm4zhctbcnhp7');
Braintree_Configuration::privateKey('336f00e6a13510923edffcddee3c32ea');

$userId = $_POST['userId'];
$amount = $_POST['amount'];
$paymentMethodNonce = strtolower($_POST['payment_method_nonce']);

// Create connection
$con = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE);
 
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
$query = "SELECT * FROM Users WHERE user_id = '$userId';";

// Check if there are results
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row)) {
	$status->error = "user_does_not_exist";
	echo json_encode($status);
} else {
	$newAmount = $row->credit + $amount;
	$result = Braintree_Transaction::sale([
	  'amount' => $amount,
	  'paymentMethodNonce' => $paymentMethodNonce,
	  'options' => [
	    'submitForSettlement' => True
	  ]
	]);

	if($result.success) {
		$query = "UPDATE Users SET credit = $newAmount WHERE user_id = $userId;";
		$result = mysqli_query($con, $query);
		if($result) {
			$status->success = true;
			$status->amount = $newAmount;
			echo json_encode($status);
		} else {
			$status->success = false;
			echo json_encode($status);
		}
		// Close connections
		mysqli_close($con);
	} else {
		$status->success = false;
		echo json_encode($status);
	}
}
?>