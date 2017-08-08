<?php

$name = strtolower($_POST['name']); 
$email = strtolower($_POST['email']);
$password = $_POST['password'];

// Create connection
$con=mysqli_connect("localhost","root","Tsnimupa55","custom-services");

// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$query = "INSERT INTO `Users` (`user_id`, `name`, `email`, `password`, `profile_picture`, `credit`) VALUES (NULL, '$name', '$email', '$password', NULL, '0');";
$result = mysqli_query($con, $query);
$status->insertId = mysqli_insert_id($con);
echo json_encode($status);
 
// Close connections
mysqli_close($con);
?>