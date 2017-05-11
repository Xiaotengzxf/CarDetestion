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
    
    var btnService : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MTabBarController.handleNotification(notification:)), name: Notification.Name("tab"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addCustomServiceButton()
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
    
    
    func addCustomServiceButton() {
        if btnService == nil {
            btnService = UIButton(frame: CGRect(x: WIDTH - 100, y: HEIGHT - 160, width: 80, height: 80))
            btnService.setImage(UIImage(named: "kefu"), for: .normal)
            btnService.backgroundColor = UIColor.rgbColorFromHex(rgb: 0x0789CD)
            btnService.layer.cornerRadius = 40
            btnService.clipsToBounds = true
            self.view?.insertSubview(btnService, at: 0)
            self.view?.bringSubview(toFront: btnService)
            btnService.addTarget(self, action: #selector(MTabBarController.jumpToCustom), for: .touchUpInside)
        }
    }
    
    func jumpToCustom() {
        DispatchQueue.global().async {
            [weak self] in
            let lgM = SCLoginManager.share()
            if lgM!.loginKefuSDK() {
                let chat = HDChatViewController(conversationChatter: "")
                chat?.visitorInfo = self?.visitorInfo()
                chat?.title = lgM!.cname
                
            }
        }
    }
    
    func visitorInfo() -> HVisitorInfo {
        let visitor = HVisitorInfo()
        visitor.name = "小明儿"
        visitor.qq = "12345678"
        visitor.phone = "13636362637"
        visitor.companyName = "环信";
        visitor.nickName = SCLoginManager.share().nickname
        visitor.email = "abv@126.com"
        visitor.desc = "环信移动客服"
        return visitor
    }

}
