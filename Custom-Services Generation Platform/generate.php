<?php

$title = $_POST['title'];
$tabTitle = $_POST['tabTitle'];
$colour1 = $_POST['colour1'];
$colour2 = $_POST['colour2'];
$colour3 = $_POST['colour3'];
$colour4 = $_POST['colour4'];
$selectedType = $_POST['selectedType'];
$notifications = $_POST['notifications'];
$categories = $_POST['categories'];

$database = "error";
$type = 'location';
if ($notifications == 1) {
  $notifications = 0;
} else {
  $notifications = 1;
}

if ($categories == 1) {
  if ($selectedType == 0) {
    $database = "custom-services-location-based-no-categories.sql";
    $type = 'location';
  } else if ($selectedType == 1) {
    $database = "custom-services-product-based-no-categories.sql";
    $type = 'product';
  } else {
    $database = "custom-services-service-based-no-categories.sql";
    $type = 'service';
  }
} else {
  if ($selectedType == 0) {
    $database = "custom-services-location-based.sql";
    $type = 'location';
  } else if ($selectedType == 1) {
    $database = "custom-services-product-based.sql";
    $type = 'product';
  } else {
    $database = "custom-services-service-based.sql";
    $type = 'service';
  }
}

$myfile = fopen("database.sql", "w") or die("Unable to open file!");
fclose($myfile);
copy('./Database-Templates/'.$database, "database.sql");
$database = "database.sql";
$systemData = "INSERT INTO `System` (`system_id`, `type`, `main_colour`, `opaque_colour`, `background_colour`, `cell_background_colour`, `main_logo`, `main_title`, `main_tab_logo`, `main_tab_title`, `geolocation_notifications`, `navigation_logo`) VALUES
(1, '" . $type . "', '" . $colour1 . "', '" . $colour2 . "', '" . $colour3 . "', '" . $colour4 . "', '', '" . $title . "', '', '" . $tabTitle . "', " . $notifications . ", '');";
file_put_contents($database, $systemData, FILE_APPEND | LOCK_EX);

$zip = new ZipArchive();
$zip->open('solution.zip', ZipArchive::CREATE | ZipArchive::OVERWRITE);
$zip->addFile($database, 'database-import.sql');
$files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator(realpath('Template-System')), RecursiveIteratorIterator::LEAVES_ONLY);
foreach ($files as $name => $file) {
    if (!$file->isDir()) {
        $filePath = $file->getRealPath();
        $relativePath = substr($filePath, strlen($rootPath) + 1);
        $zip->addFile($filePath, $relativePath);
    }
}

$res = $zip->close();
echo json_encode($res);
?>