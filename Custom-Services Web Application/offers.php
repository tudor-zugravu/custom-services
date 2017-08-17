<?php
session_start();

if (isset($_SESSION['logged_in'])) {
  if ($_SESSION['logged_in'] != "false") {
    
  } else {
    header('location:login.php');
  }
} else {
  header('location:login.php');
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title><?php echo $_SESSION['main_title']?></title>
  <link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" media="all" />
  <link href="assets/css/bootstrap-slider.min.css" rel="stylesheet" type="text/css" media="all" />
  <link href="assets/css/style.css" rel="stylesheet" type="text/css" media="all" />
  <script src="assets/js/jquery-3.2.1.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.11.0/umd/popper.min.js" integrity="sha384-b/U6ypiBEHpOf/4+1nzFpr53nxSS+GLCkfwBdFNTxtclqqenISfwAzpKaMNFNmj4" crossorigin="anonymous"></script>
  <script src="assets/js/bootstrap.min.js"></script>
  <script src="assets/js/bootstrap-slider.min.js"></script>
  <script src="assets/js/script.js"></script>
  <style>
    .custom-main-colour {
      background-color: #<?php echo $_SESSION['main_colour']?>;
    }
    .custom-opaque-colour {
      background-color: #<?php echo $_SESSION['opaque_colour']?>;
    }
    .active {
      background-color: #<?php echo $_SESSION['main_colour']?> !important;
      border-color: #<?php echo $_SESSION['main_colour']?> !important;
    }
    .slider-selection {
      background-image: linear-gradient(#<?php echo $_SESSION['main_colour']?>, #<?php echo $_SESSION['main_colour']?>);
    }
  </style>
</head>
  <body>
    <div class="container-fluid">
      <div class="row header custom-main-colour">
        <div class="col-12">
          <div class="row">
            <div class="col-3">
              <a href="index.php">
                <img src="resources/system_images/<?php echo $_SESSION['navigation_logo']?>" class="navigation-logo"/>
              </a>
            </div>
            <div class="col-6">
              <h3 class="welcome-label"> Welcome to <?php echo $_SESSION['main_title']?> </h3>
            </div>
            <div class="col-3">
              <div class="row log-out">
                <div class="col-12 session-log-out">
                  <p> Logged in as <?php echo $_SESSION['name']?> </p>
                </div>
                <div class="col-12 session-log-out">
                  <a href="index.php" id="log-out">
                    <h6> Log out </h6>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="row content">
        <div class="col-2 side-menu-container">
          <div class="list-group side-menu custom-opaque-colour">
            <a href="#" class="list-group-item list-group-item-action side-menu-button active" id="menu-button-1"> Locals </a>
            <a href="#" class="list-group-item list-group-item-action side-menu-button" id="menu-button-2"> Map View </a>
            <a href="#" class="list-group-item list-group-item-action side-menu-button" id="menu-button-3"> Favourites </a>
            <a href="#" class="list-group-item list-group-item-action side-menu-button" id="menu-button-4"> View Profile </a>
            <?php 
              if (strcmp($_SESSION['type'], "location")) { echo '<a href="#" class="list-group-item list-group-item-action side-menu-button" id="menu-button-5"> View Receipts </a>'; } 
            ?>
            <div class="filtering-options">
              <p> Filtering options </p>
              <div class="filtering-section"> 
                <p> Distance: <span id="distance-label">50</span> km </p>
                <input id="distance-slider" data-slider-id='ex1Slider' type="text" data-slider-min="1" data-slider-max="50" data-slider-step="1" data-slider-value="50"/>
              </div>
              <div class="filtering-section"> 
                <p> Time interval: <span id="time-interval-label">08:00 - 24:00</span> </p>
                <input id="time-interval-slider" type="text" class="span2" value="" data-slider-min="0" data-slider-max="64" data-slider-step="1" data-slider-value="[0,64]"/>
              </div>
              <div class="filtering-section"> 
                <p> Sort offers by </p>
                <input type="radio" name="sortBy" value="0" checked> Distance <br>
                <input type="radio" name="sortBy" value="1"> Rating <br>

                <?php 
                echo '<p id="user-id" style="display:none">' . $_SESSION['user_id'] . '</p>';
                  if (strcmp($row->type, "location")) {
                    echo '<input type="radio" id="last-sortBy" name="sortBy" value="2"> Discount <br>'; 
                    echo '<p id="system-type" style="display:none">location</p>';
                  } else {
                    echo '<input type="radio" id="last-sortBy" name="sortBy" value="2"> Price <br>';
                    if (strcmp($row->type, "product")) {
                      echo '<p id="system-type" style="display:none">product</p>';
                    } else {
                      echo '<p id="system-type" style="display:none">service</p>';
                    }
                  }
                ?>

              </div>
              <div class="filtering-section"> 
                <input type="checkbox" id="only-available-offers" name="onlyAvailableOffers" value="true" checked> Show only available offers <br>
              </div>

              <?php
              if (isset($_SESSION['has_categories'])) {
                if ($_SESSION['has_categories'] == "1") {
                  if (count($_SESSION['categories']) > 1) {
                    echo '<div class="filtering-section"> 
                            <input type="checkbox" id="all-categories-checkbox" name="allCategories" value="true" checked> Show all categories <br> 
                            <div id="categories">';
                    foreach ($_SESSION['categories'] as $category) {
                      echo '<input type="checkbox" name="category" class="category-checkbox" value="' . $category->category . '" checked> ' . $category->category . ' <br>';
                    }
                    echo '</div> </div>';
                  }
                }
              }
              ?>
            
              <div class="filtering-section"> 
                <a href="" id="search-button" class="btn btn-default form-control custom-main-colour button" role="button"> Search </a>
              </div>
            </div>
          </div>
        </div>
        <div class="col-8" style="height: 100%;">
          <div class="row top-blur"></div>
          <div class="row" style="height: 100%;">
            <div class="col-12" id="display">
            </div>
          </div>
          <div class="row bottom-blur"></div>
        </div>
        <div class="col-2 side-menu-container">
          <div class="profile-menu custom-opaque-colour">
            

            //TODO


          </div>
        </div>
      </div>
      <div class="row footer custom-main-colour">

      </div>
    </div>

    <script>
      $('#distance-slider').slider();
      $('#distance-slider').on("change", function(slideEvt) {
        $("#distance-label").text(slideEvt.value.newValue);
      });
      $("#time-interval-slider").slider();
      $('#time-interval-slider').on("change", function(slideEvt) {
        if (slideEvt.value.newValue[0] === slideEvt.value.newValue[1]) {
          if (slideEvt.value.newValue[0] === 0) {
            slideEvt.value.newValue[1] = 1;
          } else {
            slideEvt.value.newValue[0]--;
          }
          $('#time-interval-slider').slider('setValue', slideEvt.value.newValue);
        }
        $("#time-interval-label").text(getTime(slideEvt.value.newValue[0]) + " - " + getTime(slideEvt.value.newValue[1]));
      });
    </script>
    <script async defer
       src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAV_j2P9H-iYPgG72iZl_bl1qFon7jMjOk">
    </script>
  </body>
</html>