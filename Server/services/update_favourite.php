<?php
 
$userId = $_POST['userId'];
$locationId = $_POST['locationId'];
$favourite = $_POST['favourite'];

// Create connection
$con=mysqli_connect("localhost","root","Tsnimupa55","custom-services");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
$query = "SELECT * FROM Corelations WHERE user_id = '$userId' AND location_id = '$locationId';";

// Check if there are results
$result = mysqli_query($con, $query);
$row = $result->fetch_object();
// Check if there are results
if (is_null($row))
{
	$query = "INSERT INTO Corelations (corelation_id, user_id, location_id, favourite, rating) VALUES (NULL, $userId, $locationId, $favourite, NULL);";
	$result = mysqli_query($con, $query);
	echo $result;
} else {
	$query = "UPDATE Corelations SET favourite = $favourite WHERE user_id = '$userId' AND location_id = '$locationId';";
	$result = mysqli_query($con, $query);
	echo $result;
}
 
// Close connections
mysqli_close($con);
?>