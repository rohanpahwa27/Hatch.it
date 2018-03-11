//
//  AppDelegate.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/13/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//
struct values {
    static var link = false
    static var uuid = ""
}
import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import GoogleSignIn
import GooglePlaces
import GoogleMaps
import Stripe
import FBSDKCoreKit
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        values.link = false
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        STPPaymentConfiguration.shared().publishableKey = "pk_test_6pRNASCoBOKtIshFeQd4XMUh"
        FirebaseApp.configure()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, error) in
            if error != nil {
            }
            else{
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GMSPlacesClient.provideAPIKey("AIzaSyANn02fonEkYgIlOdWVnSlnnG3Rcj7nhlU")
        GMSServices.provideAPIKey("AIzaSyANn02fonEkYgIlOdWVnSlnnG3Rcj7nhlU")
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = DynamicLinks.dynamicLinks() else {
            return false
        }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
        }
        return handled
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = Messaging.messaging().fcmToken
        if(Auth.auth().currentUser?.uid != nil){
            Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Notification Token": token!])
        }
        
    }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            values.link = false
                values.uuid = (url.host?.replacingOccurrences(of: "Event", with: ""))!
                if(url.host?.contains("Event"))!{
                         values.link = true
                         let storyboard = UIStoryboard(name: "Main", bundle: nil)
                         let scheduleController = storyboard.instantiateViewController(withIdentifier: "tabView")
                         self.window!.rootViewController = scheduleController
                         self.window!.makeKeyAndVisible()
                }
            
                return GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,annotation: [:]) || FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if (DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)) != nil {
            return true
        }
        return false
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    func applicationWillTerminate(_ application: UIApplication) {
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("userInfo  \(userInfo)")
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //let newToken = InstanceID.instanceID().token()
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
}

