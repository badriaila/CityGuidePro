//
//  AppDelegate.swift
//  CityGuidePro
//
//  Updated by AJ
//


import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Check if the pop-up has already been shown
           let hasShownPopup = UserDefaults.standard.bool(forKey: "hasShownPopup")
           
           if !hasShownPopup {
               // Show the pop-up view controller
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let popupViewController = storyboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
               
               // Set the pop-up view controller as the root view controller
               window?.rootViewController = popupViewController
               window?.makeKeyAndVisible()
               
               // Update the user defaults to indicate that the pop-up has been shown
               UserDefaults.standard.set(true, forKey: "hasShownPopup")
           }
           
           return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

