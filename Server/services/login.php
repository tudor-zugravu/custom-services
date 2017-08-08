<?php
 
$email = strtolower($_POST['email']);
$password = $_POST['password'];

// Create connection
$con=mysqli_connect("localhost","root","Tsnimupa55","custom-services");

// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$query = "SELECT * FROM Users WHERE email = '$email' AND password = '$password';";
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row))
{
	$status->status = "failed";
	echo json_encode($status);
} else {
	echo json_encode($row);
}
 
// Close connections
mysqli_close($con);
?>