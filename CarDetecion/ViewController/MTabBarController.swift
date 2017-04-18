//
//  MTabBarController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/30.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

var recordIndex = -1

class MTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MTabBarController.handleNotification(notification:)), name: Notification.Name("tab"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Int] {
                    let index = userInfo["index"] ?? 0
                    recordIndex = index
                    self.selectedIndex = 3
                }
            }
        }
    }

}
