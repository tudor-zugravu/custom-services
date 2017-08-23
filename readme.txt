This archive contains all five components that comprise the final project's solution:

1. Custom-Services Database Templates - the templates for creating the six database structures
	1.1. custom-services-location-based.sql
	1.2. custom-services-location-based-no-categories.sql
	1.3. custom-services-product-based.sql
	1.4. custom-services-product-based-no-categories.sql
	1.5. custom-services-service-based.sql
	1.6. custom-services-service-based-no-categories.sql

2. Custom-Services Generation Platform - the system responsible with gathering potential client's input and generating tailored solutions
	2.1. Database-Templates (same as above)
	2.2. assets
		2.2.1. css
			2.2.1.1. style.css - generation system's customisation file
			2.2.1.2. bootstrap.min.css - Bootstrap customisation file
			2.2.1.3. bootstrap.min.css.map - Bootstrap customisation file
		2.2.2. js
			2.2.2.1. script.js - generation system's script file
			2.2.2.2. bootstrap.min.js - Bootstrap script file
			2.2.2.3. jquery-3.2.1.min.js - JQuery script file
			2.2.2.4. popper.min.js - Popper script file - needed by the Bootstrap component
			2.2.2.5. popper.min.js.map - Popper script file - needed by the Bootstrap component
	2.3. libraries/braintree-php-3.23.1 - the Braintree component that authorises card transactions
	2.4. Template-System
		2.4.1. Template-iOS-Application - the iOS application template sent as part of the solution
		2.4.2. Template-Website - the server and web application templates sent as part of the solution
	2.5. generate.php - PHP file that manages the generation request by creating the final database file and archiving the solution
	2.6. index.php - the web page form used to provide the needed input for the system generation

3. Custom-Services Server - the server files needed for the system's functionalities
	3.1. services - the folder with the PHP files that handle the computing processes, the request handling and the database interactions
		3.1.1. config.php - the configuration file where the database name and server address have to be inputed in order for the system to work
		3.1.2. categories.php - handling the categories requests
		3.1.3. change_password.php - handling the password changing requests
		3.1.4. receipts.php - handling the receipts requests
		3.1.5. login.php - handling the authentication requests
		3.1.6. register.php - handling the register requests
		3.1.7. offers.php - handling the offers requests
		3.1.8. payment.php - handling the payment requests
		3.1.9. product_checkout.php - handling the product purchasing requests
		3.1.10. service_checkout.php - handling the service booking and purchasing requests
		3.1.11. rating.php - handling the rating requests for product and service based systems
		3.1.12. location_rating.php - handling the rating requests for location based systems
		3.1.13. redeem_offer.php - handling the receipt redeemal requests
		3.1.14. system.php - handling the system requests
		3.1.15. update_favourite.php - handling the favourites corelations requests
		3.1.16. update_user_details.php - handling the profile editing requests
		3.1.17. appointments.php - handling the appointments requests
	3.2. libraries/braintree-php-3.23.1 - the Braintree component that authorises card transactions
			
4. Custom-Services Web Application - the web client interface template for the vendor system's customers
	4.1. assets
		4.1.1. css
			4.1.1.1. style.css - web application's customisation file
			4.1.1.2. bootstrap.min.css - Bootstrap customisation file
			4.1.1.3. bootstrap-slider.min.css - the slider component's customisation file
			4.1.1.4. bootstrap.min.css.map - Bootstrap customisation file
		4.1.2. js
			4.1.2.1. script.js - web application's script file
			4.1.2.2. bootstrap.min.js - Bootstrap script file
			4.1.2.3. bootstrap-slider.min.js - the slider component's script file
			4.1.2.4. jquery-3.2.1.min.js - JQuery script file
			4.1.2.5. popper.min.js - Popper script file - needed by the Bootstrap component
			4.1.2.6. popper.min.js.map - Popper script file - needed by the Bootstrap component
	4.2. resources - the image folder with system, user profile and vendor images
	4.3. error.php - the web page presented in case of an error
	4.4. index.php - the PHP file that handles the system customisation process and the session management
	4.5. login.php - the web page for logging in and registering
	4.6. offers.php - the main web page that displays the vendor system's information
	4.7. profile_picture_upload.php - the PHP file that handles image uploads
	4.8. set_session_variables.php - the PHP file used to set session variables form JavaScript

5. Custom-Services iOS Application - the iOS client mobile application template for the vendor system's customers
	5.1. Custom-Services - the application bundle
		5.1.1. Assets.xcassets - the folder containing all the images required by the system
		5.1.2. Info.plist - the file used for setting the application's permissions
		* In the project editor the classes are organised by type - model, view, controller or Utils (additional files). They are scattered here by Xcode. 
		5.1.3. Models - the model classes used by the system
			5.1.3.1. OfferModel.swift - the structure class for the offers
			5.1.3.2. RedeiptModel.swift - the structure class for the receipts
			5.1.3.3. Checkpoint.swift - the structure class for the augmented reality checkpoints
			5.1.3.4. PointModel.swift - the structure class for the geolocation notifications coordinates
			5.1.3.5. OffersModel.swift - the class for the offer requests
			5.1.3.6. SystemModel.swift - the class for the system requests
			5.1.3.7. LogInModel.swift - the class for the authentication requests
			5.1.3.8. RegisterModel.swift - the class for the registration requests
			5.1.3.9. ProfileModel.swift - the class for the profile related requests
			5.1.3.10. FavouriteModel.swift - the class for the favourites management requests
			5.1.3.11. CheckoutModel.swift - the class for the purchasing requests
			5.1.3.12. RatingModel.swift - the class for the location based system's rating requests
			5.1.3.13. CheckoutRatingModel.swift - the class for the product or service based system's rating requests
			5.1.3.14. OfferModel.swift - the class for the offers
			5.1.3.15. AppointmentsModel.swift - the class for the appointments related requests
			5.1.3.16. ReceiptsModel.swift - the class for the receipts related requests
			5.1.3.17. DirectionsModel.swift - the class for the navigation related requests
		5.1.4. Controllers - the controller classes that manage the app's logic
			5.1.4.1 InitialViewController.swift - the front controller that manages the initial interaction
			5.1.4.2 OffersListViewController.swift - the controller that manages the offers table
			5.1.4.3 MapViewController.swift - the controller that manages the map view's logic
			5.1.4.4 FavouritesListViewController.swift - the controller that manages the favourite offers table
			5.1.4.5 ReceiptsListViewController.swift - the controller that manages the receipts table
			5.1.4.6 PopoverFilterViewController.swift - the controller that manages the filtering overlay
			5.1.4.7 LogInViewController.swift - the controller that manages the authentication logic
			5.1.4.8 RegisterViewController.swift - the controller that manages the registration logic
			5.1.4.9 ProfileViewController.swift - the controller that manages the profile management logic
			5.1.4.10 LocationDetailsViewController.swift - the controller that manages the location details logic and appointments
		5.1.5. Views - the view classes that describe the behaviour and aspect of the visual elements
			5.1.5.1. CheckpointView.swift - the view class that describes the graphical elements used in the augmented reality navigation
			5.1.5.2. OffersTableViewCell.swift - the offers table cell visual customisation and behaviour rules
			5.1.5.2. CateboriesTableViewCell.swift - the categories table cell visual customisation and behaviour rules
			5.1.5.2. ReceiptsTableViewCell.swift - the receipts table cell visual customisation and behaviour rules
			5.1.5.2. UnderlinedLabel.swift - an external file that provides the graphical rules for underlining labels
			5.1.5.2. MapMarkerView.swift - the Google Maps marker visual customisation and behaviour rules
		5.1.6. Utils - addition files used throughout the application
			5.1.6.1. Utils.swift - file used to store all the global auxiliary methods used
			5.1.6.2. DropMenuButton.swift - external file for the creation of the dropdown menu
	5.2. Custom-Services.xcworkspace - the file used to open the project in Xcode
	5.2. The rest of the directories and files are needed for the project's successful building
