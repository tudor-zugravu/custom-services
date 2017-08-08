<?php
 
$userId = $_POST['userId'];
$oldPassword = $_POST['oldPassword'];
$newPassword = $_POST['newPassword'];

// Create connection
$con=mysqli_connect("localhost","root","Tsnimupa55","custom-services");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
$query = "SELECT * FROM Users WHERE user_id = '$userId';";

// Check if there are results
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row))
{
	$status->error = "user_does_not_exist";
	echo json_encode($status);
} else {
	if(strcmp($oldPassword, $row->password) == 0) {
		$query = "UPDATE Users SET password = '$newPassword' WHERE user_id = $userId;";
		$result = mysqli_query($con, $query);
		$status->status = $result;
		echo json_encode($status);	
	} else {
		$status->status = false;
		echo json_encode($status);	
	}	
}
 
// Close connections
mysqli_close($con);
?>