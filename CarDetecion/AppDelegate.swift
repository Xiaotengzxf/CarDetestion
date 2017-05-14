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

var upLoadCount = 0 // 上传图片的数量

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , JPUSHRegisterDelegate {

    var window: UIWindow?
    var orderInfo : [String : [String : String]] = [:]
    let createBill = "external/app/finishCreateAppCarBill.html"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Bugly.start(withAppId: "18e9624730")
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleNotification(notification:)), name: Notification.Name("app"), object: nil)
        
        let option = HOptions()
        option.appkey = "1112170506115622#kefuchannelapp41042"
        option.tenantId = "41042"
        //option.apnsCertName = ""
        let initError = HChatClient.shared().initializeSDK(with: option)
        if initError != nil {
            print("环信客服初始化失败")
        }
        
        // 通知注册实体类
        let entity = JPUSHRegisterEntity();
        entity.types = Int(JPAuthorizationOptions.alert.rawValue) |  Int(JPAuthorizationOptions.sound.rawValue) |  Int(JPAuthorizationOptions.badge.rawValue);
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self);
        // 注册极光推送
        JPUSHService.setup(withOption: launchOptions, appKey: "0cc682f084991254e7b0dd7a", channel:"Publish channel" , apsForProduction: false);
        // 获取推送消息
        let remote = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? Dictionary<String,Any>;
        // 如果remote不为空，就代表应用在未打开的时候收到了推送消息
        if remote != nil {
            // 收到推送消息实现的方法
            self.perform(#selector(receivePush), with: remote, afterDelay: 1.0);
        }
        
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            JPUSHService.setAlias(username, callbackSelector: nil, object: nil)
        }
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    
    // MARK: -JPUSHRegisterDelegate
    // iOS 10.x 需要
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo;
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo);
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo;
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo);
        }
        completionHandler();
        // 应用打开的时候收到推送消息
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo);
        completionHandler(UIBackgroundFetchResult.newData);
    }
    
    // 接收到推送实现的方法
    func receivePush(_ userInfo : Dictionary<String,Any>) {
        // 角标变0
        UIApplication.shared.applicationIconBadgeNumber = 0
        // 剩下的根据需要自定义
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("apns fail:\(error.localizedDescription)")
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
        application.applicationIconBadgeNumber = 0
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

    // 处理通知
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userinfo = notification.userInfo as? [String : String] {
                    orderInfo[userinfo["orderNo"]!] = ["price" : userinfo["price"]! , "remark" : userinfo["remark"]!]
                    self.perform(#selector(AppDelegate.showAlertView(userinfo:)), with: userinfo, afterDelay: 0.1)
                }
            }else if tag == 2 {
                if let userinfo = notification.userInfo as? [String : String] {
                    submitBill(orderNo: userinfo["orderNo"] ?? "")
                }
            }
        }
    }
    
    func showAlertView(userinfo : [String : String]) {
        self.showAlert(title: "温馨提示", message: "评估单：\(userinfo["orderNo"]!)，在后台提交中", button: "确认")
    }
    
    // 提交订单
    func submitBill(orderNo : String)  {
        if orderNo.characters.count > 0 {
            DispatchQueue.global().async {
                [weak self] in
                let username = UserDefaults.standard.string(forKey: "username")
                var params = ["userName" : username!]
                params["carBillId"] = orderNo
                params["clientName"] = "iOS"
                params["preSalePrice"] = self?.orderInfo[orderNo]?["price"] ?? ""
                params["mark"] = self?.orderInfo[orderNo]?["remark"] ?? ""
                NetworkManager.sharedInstall.request(url: self!.createBill, params: params) {(json, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        self?.showAlert(title: "温馨提示", message: "评估单：\(orderNo)，提交失败；原因：\(error!.localizedDescription)", button: "确认")
                    }else{
                        if let data = json , data["success"].boolValue {
                            self?.showAlert(title: "温馨提示", message: "评估单：\(orderNo)，已提交成功！", button: "确认")
                        }else{
                            if let message = json?["message"].string {
                                self?.showAlert(title: "温馨提示", message: "评估单：\(orderNo)，提交失败；原因：\(message)", button: "确认")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 显示提示框
    func showAlert(title : String?, message : String , button : String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .cancel, handler: { (action) in
            
        }))
        window?.rootViewController?.present(alert, animated: true) {
            
        }
    }
    
}

