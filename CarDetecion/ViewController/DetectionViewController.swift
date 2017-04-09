//
//  DetectionViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class DetectionViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblUnSubmit: UILabel!
    @IBOutlet weak var lblUnpass: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblPass: UILabel!
    @IBOutlet weak var lblAdvertise: UILabel!
    @IBOutlet weak var btnAdvertise: UIButton!
    @IBOutlet weak var vCarStatus: UIView!
    @IBOutlet weak var vPreDetection: UIView!
    @IBOutlet weak var vDetection: UIView!
    @IBOutlet weak var lcRight: NSLayoutConstraint!
    @IBOutlet weak var lcLeft: NSLayoutConstraint!
    
    let applyCount = "external/app/getApplyCountInfo.html"
    let latestList = "external/news/latestList.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getApplyCount()
        getLatestList(type: "新闻公告")
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.clear
        let abStr = NSMutableAttributedString(string: "详情...")
        abStr.addAttributes([NSUnderlineStyleAttributeName : 1 , NSForegroundColorAttributeName : UIColor.black , NSFontAttributeName : UIFont.systemFont(ofSize: 14)], range: NSMakeRange(0, 2))
        btnAdvertise.setAttributedTitle(abStr, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.handleGestureRecognizer(recognizer:)))
        
        vDetection.addGestureRecognizer(tap)
        
        lcRight.constant = (WIDTH - 240) / 4
        lcLeft.constant = (WIDTH - 240) / 4
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetectionViewController.handleNotification(notification:)), name: Notification.Name("detection"), object: nil)
        
        
        if let orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
            lblUnSubmit.text = "共有\(orders.count)单"
        }else{
            lblUnSubmit.text = "共有0单"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func showAdvertiseDetail(_ sender: Any) {
    }
    
    // 处理通知
    func handleNotification(notification : Notification) {
        
    }
    
    func handleGestureRecognizer(recognizer : UITapGestureRecognizer) {
        if recognizer.view == vDetection {
            self.performSegue(withIdentifier: "toNewDetection", sender: self)
        }
    }
    
    // 获取审核中，未通过及通过的订单总数
    func getApplyCount() {
        let username = UserDefaults.standard.string(forKey: "username")
        let params = ["userName" : username!]
        NetworkManager.sharedInstall.request(url: applyCount, params: params) {[weak self] (json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        for j in array {
                            if j["infoType"].stringValue == "finishCount" {
                                self?.lblPass.text = "共有\(j["countInfo"].int ?? 0)单"
                            }else if j["infoType"].stringValue == "refuseCount" {
                                self?.lblUnpass.text = "共有\(j["countInfo"].int ?? 0)单"
                            }else if j["infoType"].stringValue == "processCount" {
                                self?.lblReview.text = "共有\(j["countInfo"].int ?? 0)单"
                            }else if j["infoType"].stringValue == "allCount" {
                                //self?.lblReview.text = "共有\(j["countInfo"].string ?? "0")单"
                            }
                        }
                    }
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    
    // 获取最新公告
    func getLatestList(type : String) {
        NetworkManager.sharedInstall.request(url: latestList, params: ["classType" : type]) {(json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["success"].boolValue {
                    print(data)
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
