//
//  AppDelegate.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var headView : UIView!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 66/255.0, green: 83/255.0, blue: 90/255.0, alpha: 1)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 23/255.0, green: 177/255.0, blue: 140/255.0, alpha: 1)], for: .selected)
        application.setStatusBarStyle(.lightContent, animated: true)
        
        IQKeyboardManager.sharedManager().enable = true
        
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            print("当前登录用户：\(username)")
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let login = storyboard.instantiateViewController(withIdentifier: "login")
            window?.rootViewController = login
        }
        
        return true
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
        if headView == nil {
            headView = UIView()
            headView.backgroundColor = UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1)
            headView.translatesAutoresizingMaskIntoConstraints = false
            window?.addSubview(headView)
            window?.bringSubview(toFront: headView)
            window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: .directionLeadingToTrailing, metrics: nil, views: ["view" : headView]))
            window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view(20)]", options: .directionLeadingToTrailing, metrics: nil, views: ["view" : headView]))
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CarDetecion")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

