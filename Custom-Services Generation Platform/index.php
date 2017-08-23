<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title><?php echo $_SESSION['main_title']?></title>
  <link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" media="all" />
  <link href="assets/css/style.css" rel="stylesheet" type="text/css" media="all" />
  <script src="assets/js/jquery-3.2.1.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.11.0/umd/popper.min.js" integrity="sha384-b/U6ypiBEHpOf/4+1nzFpr53nxSS+GLCkfwBdFNTxtclqqenISfwAzpKaMNFNmj4" crossorigin="anonymous"></script>
  <script src="assets/js/bootstrap.min.js"></script>
  <script src="https://js.braintreegateway.com/web/dropin/1.6.1/js/dropin.min.js"></script>
  <script src="assets/js/script.js"></script>
  <style>
    .custom-main-colour {
      background-color: #EB2E20;
    }
    .custom-opaque-colour {
      background-color: #FDEAE9;
    }
    .active {
      background-color: #EB2E20 !important;
      border-color: #EB2E20 !important;
    }
    .slider-selection {
      background-image: linear-gradient(#EB2E20, #EB2E20);
    }
  </style>
</head>
  <body>
    <div class="container-fluid">
      <div class="row header custom-main-colour">
        <div class="col-12">
          <div class="row">
            <div class="col-3"></div>
            <div class="col-6">
              <h3 class="welcome-label"> Welcome to Custom Services </h3>
            </div>
            <div class="col-3"></div>
          </div>
        </div>
      </div>
      <div class="row content">
        <div class="col-2 side-menu-container">
          <div class="list-group side-menu custom-opaque-colour"></div>
        </div>
        <div class="col-8" style="height: 100%;">

          <div class="row" id="details-container" style="height: 100%;">
            <div class="col-12" id="system-form" style="height: 100%;">
              <div class="row top-blur"></div>
              <div class="row" style="height: 100%; overflow-y: scroll; overflow-x:hidden;">
                <div class="col-3"></div>
                <div class="col-6 generate">
                  <div class="row">
                    <div class="col-2"></div>
                    <div class="col-8">
                      <form id="generate-form" action="" method="post" role="form">
                        <div class="form-group">
                          <input type="text" name="generate-title" id="title" tabindex="1" class="form-control" placeholder="Retail system title" value="">
                        </div>
                        <div class="form-group">
                          <input type="text" name="generate-tab-title" id="tab-title" tabindex="1" class="form-control" placeholder="Retail system tab title" value="">
                        </div>
                        <div class="form-group">
                          <input type="text" name="generate-colour1" id="colour1" tabindex="1" class="form-control" placeholder="Retail system's main colour" value="">
                        </div>
                        <div class="form-group">
                          <input type="text" name="generate-colour2" id="colour2" tabindex="1" class="form-control" placeholder="Retail system's secondary colour" value="">
                        </div>
                        <div class="form-group">
                          <input type="text" name="generate-colour3" id="colour3" tabindex="1" class="form-control" placeholder="Retail system's background colour" value="">
                        </div>
                        <div class="form-group">
                          <input type="text" name="generate-colour4" id="colour4" tabindex="1" class="form-control" placeholder="Retail system's cells background colour" value="">
                        </div>
                        <div class="form-group margin-top">
                          <p class="no-margin"> Select the type of system </p>
                          <select class="form-control" id="system-type-select">
                            <option class="details-text" value="0">Location based</option>
                            <option class="details-text" value="1">Product based</option>
                            <option class="details-text" value="2">Service based</option>
                          </select>
                        </div>
                        <div class="form-group margin-top">
                          <p class="no-margin"> Are there multiple offer categories? </p>
                          <select class="form-control" id="system-categories-select">
                            <option class="details-text" value="0">Yes</option>
                            <option class="details-text" value="1">No</option>
                          </select>
                        </div>
                        <div class="form-group margin-top">
                          <p class="no-margin"> Enable geolocation notifications? </p>
                          <select class="form-control" id="system-geolocations-select">
                            <option class="details-text" value="0">Yes</option>
                            <option class="details-text" value="1">No</option>
                          </select>
                        </div>
                        <div class="form-group">
                          <div id="dropin-container"></div>
                          <a href="#" id="payment-submit" class="btn btn-default form-control custom-main-colour button no-display" role="button">Proceed </a>
                        </div>
                        <div class="form-group">
                          <div class="row">
                            <div class="col-3"></div>
                            <div class="col-6">
                              <input type="submit" name="generate-button" id="generate-button" tabindex="3" class="btn btn-default form-control custom-main-colour button" value="Generate system">
                            </div>
                            <div class="col-3"></div>
                          </div>
                        </div>
                      </form>
                    </div>
                    <div class="col-2"></div>
                  </div>
                </div>
                <div class="col-3"></div>
              </div>
              <div class="row bottom-blur"></div>
            </div>
          </div>
        </div>
        <div class="col-2 side-menu-container">
          <div class="row profile-menu custom-opaque-colour"></div>
        </div>
      </div>
      <div class="row footer custom-main-colour"></div>
    </div>

    <script></script>
  </body>
</html>