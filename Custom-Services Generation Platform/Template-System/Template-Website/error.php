<?php
session_start();
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Error</title>
  <script src="assets/js/jquery-3.2.1.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.11.0/umd/popper.min.js" integrity="sha384-b/U6ypiBEHpOf/4+1nzFpr53nxSS+GLCkfwBdFNTxtclqqenISfwAzpKaMNFNmj4" crossorigin="anonymous"></script>
  <script src="assets/js/bootstrap.min.js"></script>
  <script src="assets/js/script.js"></script>
  <link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" media="all" />
  <link href="assets/css/style.css" rel="stylesheet" type="text/css" media="all" />
  <style>
    .custom-main-colour {
      background-color: #686868;
    }
  </style>
</head>
  <body>
    <div class="row header custom-main-colour">
      <div class="col-12">
        <div class="row">
          <div class="col-3"></div>
          <div class="col-6">
            <h3 class="welcome-label"> Oops! </h3>
          </div>
          <div class="col-3"></div>
        </div>
      </div>
    </div>
    <div class="row content">
      <div class="col-3"></div>
      <div class="col-6">
        <div class="row">
          <div class="col-3"></div>
          <div class="col-6 login">
            <div class="row">
              <div class="col-4"></div>
              <div class="col-4">
                <img src="resources/system_images/ban.png" class="error-logo"/>
              </div>
              <div class="col-4"></div>
            </div>
            <div class="row">
              <div class="col-2"></div>
              <div class="col-8">
                <h5 id="error-message"> There has been a problem </h5>
                <a href="index.php" class="btn btn-default form-control custom-main-colour button" role="button">Try again</a>
              </div>
              <div class="col-2"></div>
            </div>
          </div>
          <div class="col-3"></div>
        </div>

      </div>
      <div class="col-3"></div>
    </div>
    <div class="row footer custom-main-colour">

    </div>

    <?php

      // $con=mysqli_connect("localhost","zugravux_admin","Tsnimupa55","zugravux_EventPlanner");

      // $sql = "SELECT * FROM System WHERE system_id = 1";
       
      // if ($result = mysqli_query($con, $sql))
      // {
      //   // If so, then create a results array and a temporary one
       
      //   // Loop through each row in the result set
      //   $row = $result->fetch_object();

      //   echo "<script>
      //           document.getElementById(\"banner-image\").src=\"resources/{$row->folder}/banner.png\";
      //           document.getElementById(\"the-title\").innerHTML=\"{$row->titlu}\";
      //           document.getElementById(\"the-date\").innerHTML=\"{$row->data}\";
      //           $(\".header\").css( \"background-color\", \"#{$row->culoare1}\");
      //           $(\".content\").css( \"background-color\", \"#{$row->culoare3}\");
      //           $(\".front-page-button\").css( \"background-color\", \"#{$row->culoare1}\");
      //         </script>";
      // }
    ?>

  </body>
</html>
