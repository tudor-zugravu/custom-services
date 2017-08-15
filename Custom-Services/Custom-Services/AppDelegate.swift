//
//  AppDelegate.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 31/07/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDq0NHQJFAFPFGrQzEiizNliDANjt3pe7k")
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]){
            (granted,error) in
            if granted{
                application.registerForRemoteNotifications()
            } else {
                print("User Notification permission denied: \(error?.localizedDescription)")
            }
        }
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print(region.identifier)
            let name = getName(identifier: region.identifier)
            if UIApplication.shared.applicationState == .active {
                let alertView = UIAlertController(title: "",
                                                  message: "You are close to \(name)" as String, preferredStyle:.alert)
                let okAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                alertView.addAction(okAction)
                window?.rootViewController?.present(alertView, animated: true, completion: nil)
            } else {
                // Otherwise present a local notification
                let notification = UILocalNotification()
                notification.alertBody = "You are close to \(name)"
                notification.soundName = "Default"
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
    }
    
    func getName(identifier: String) -> String {
        
        if (UserDefaults.standard.value(forKey: "storedPoints") != nil) {
            if let data = UserDefaults.standard.data(forKey: "storedPoints"),
                let points = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PointModel] {
                let point = points.filter({ "\($0.id!)" == identifier})[0]
                return point.name!
            }
        }
        return ""
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

