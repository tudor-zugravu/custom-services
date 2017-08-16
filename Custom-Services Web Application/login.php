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
          <div class="col-6">
            <h3 class="welcome-label"> Welcome to <?php echo $_SESSION['main_title']?> </h3>
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
              <div class="col-3"></div>
              <div class="col-6">
                <img src="resources/system_images/<?php echo $_SESSION['main_logo']?>" class="login-main-logo"/>
              </div>
              <div class="col-3"></div>
            </div>
            <div class="row">
              <div class="col-12">
                <form id="login-form" action="" method="post" role="form" style="display: block;">
                  <div class="form-group">
                    <input type="text" name="email" id="email" tabindex="1" class="form-control" placeholder="Email" value="">
                  </div>
                  <div class="form-group">
                    <input type="password" name="password" id="password" tabindex="2" class="form-control" placeholder="Password">
                  </div>
                  <div class="form-group">
                    <div class="row">
                      <div class="col-6">
                        <input type="submit" name="login-button" id="login-button" tabindex="3" class="btn btn-default form-control custom-main-colour button" value="Log In">
                      </div>
                      <div class="col-6">
                        <a href="#" id="create-account" class="btn btn-default form-control custom-main-colour button" role="button">Create account</a>
                      </div>
                    </div>
                  </div>
                </form>
                <form id="register-form" action="" method="post" role="form" style="display: none;">
                  <div class="form-group">
                    <input type="text" name="register-name" id="name" tabindex="1" class="form-control" placeholder="Name" value="">
                  </div>
                  <div class="form-group">
                    <input type="email" name="register-email" id="email" tabindex="1" class="form-control" placeholder="Email Address" value="">
                  </div>
                  <div class="form-group">
                    <input type="password" name="register-password" id="password" tabindex="2" class="form-control" placeholder="Password">
                  </div>
                  <div class="form-group">
                    <input type="password" name="register-confirm-password" id="confirm-password" tabindex="2" class="form-control" placeholder="Confirm Password">
                  </div>
                  <div class="form-group">
                    <div class="row">
                      <div class="col-6">
                        <input type="submit" name="register-button" id="register-button" tabindex="3" class="btn btn-default form-control custom-main-colour button" value="Register">
                      </div>
                      <div class="col-6">
                        <a href="#" id="create-account-back" class="btn btn-default form-control custom-main-colour button" role="button">Back</a>
                      </div>
                    </div>
                  </div>
                </form>
              </div>
            </div>
          </div>
          <div class="col-3"></div>
        </div>

      </div>
      <div class="col-3"></div>
    </div>
    <div class="row footer custom-main-colour">

    </div>
  </body>
</html>
