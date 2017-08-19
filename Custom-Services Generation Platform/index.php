<?php
$myfile = fopen("database.sql", "w") or die("Unable to open file!");
fclose($myfile);
echo copy("database-templates/custom-services-location-based.sql","database.sql");
$database = "database.sql";
$systemData = "INSERT INTO `System` (`system_id`, `type`, `main_colour`, `opaque_colour`, `background_colour`, `cell_background_colour`, `main_logo`, `main_title`, `main_tab_logo`, `main_tab_title`, `geolocation_notifications`, `navigation_logo`) VALUES
(1, 'location', 'EB2E20', 'FDEAE9', 'FFFFFF', 'FFFFFF', 'drinkUpMainLogo.png', 'Drink Up!', 'drinkUpMainTab.png', 'Locals', 1, 'drinkUpNavigationLogo.png');";
echo file_put_contents($database, $systemData, FILE_APPEND | LOCK_EX);

?>