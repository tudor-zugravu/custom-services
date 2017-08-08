<?php

require_once('../libraries/braintree-php-3.23.1/lib/Braintree.php');

Braintree_Configuration::environment('sandbox');
Braintree_Configuration::merchantId('9579dnmk65pnbf2z');
Braintree_Configuration::publicKey('8ypkm4zhctbcnhp7');
Braintree_Configuration::privateKey('336f00e6a13510923edffcddee3c32ea');

$userId = $_POST['userId'];
$amount = $_POST['amount'];
$paymentMethodNonce = strtolower($_POST['payment_method_nonce']);

$result = Braintree_Transaction::sale([
  'amount' => $amount,
  'paymentMethodNonce' => $paymentMethodNonce,
  'options' => [
    'submitForSettlement' => True
  ]
]);

echo json_encode($result);

// echo json_encode($result);
// // Create connection
// $con=mysqli_connect("localhost","root","Tsnimupa55","custom-services");

// // Check connection
// if (mysqli_connect_errno())
// {
//   echo "Failed to connect to MySQL: " . mysqli_connect_error();
// }

// $query = "SELECT * FROM Users WHERE email = '$email' AND password = '$password';";
// $result = mysqli_query($con, $query);
// $row = $result->fetch_object();
// // Check if there are results
// if (is_null($row))
// {
	// $status->status = "failed";
	// echo json_encode($status);
// } else {
// 	echo json_encode($row);
// }
 
// // Close connections
// mysqli_close($con);
?>