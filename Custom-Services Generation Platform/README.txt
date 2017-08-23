1. Go to Utils.swift and add your server’s address at the top of the file, in the _serverAddress variable, as well as the Google API Key with the iOS API and the JavaScript API enabled
2. Set a+x permissions to the folder “solution/var/www/html/generate/Template-System/Template-iOS-Application/Pods/Target\ Support\ Files/Pods-Custom-Services/“
3. Change provisioning profile in the iOS project
4. Go to config.php at “services/config.php” on the server and set the GOOGLE_API_KEY variable to the same Google API Key.
5. Upload the contents of Template-Website in your server’s “html” folder
6. Import ‘database-import.sql’ in phpMyAdmin