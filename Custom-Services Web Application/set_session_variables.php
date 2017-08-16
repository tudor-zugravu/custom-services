<?php
session_start();

foreach($_POST as $key => $value){
	$_SESSION[$key] = $value;
	$response->$key = $value;
}

echo json_encode($response);
?>