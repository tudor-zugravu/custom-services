<?php
session_start();
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title><?php echo $_SESSION['main_title']?></title>
  <script src="assets/js/jquery-3.2.1.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.11.0/umd/popper.min.js" integrity="sha384-b/U6ypiBEHpOf/4+1nzFpr53nxSS+GLCkfwBdFNTxtclqqenISfwAzpKaMNFNmj4" crossorigin="anonymous"></script>
  <script src="assets/js/bootstrap.min.js"></script>
  <script src="assets/js/script.js"></script>
  <link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" media="all" />
  <link href="assets/css/style.css" rel="stylesheet" type="text/css" media="all" />
  <style>
    .custom-main-colour {
      background-color: #<?php echo $_SESSION['main_colour']?>;
    }
  </style>
</head>
  <body>
    <div class="row header custom-main-colour">
      <div class="col-12">
        <div class="row">
          <div class="col-3"></div>
          <div class="col-6"></div>
          <div class="col-3"></div>
        </div>
      </div>
    </div>
    <div class="row content">
      <div class="col-2 side-menu custom-opaque-color">
        <h1><?php echo $_SESSION['name']?></h1>
        <a href="#" id="log-out" class="btn btn-default form-control custom-main-colour button" role="button">Log out</a>
      </div>
    </div>
    <div class="row footer custom-main-colour">

    </div>
  </body>
</html>