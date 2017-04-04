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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getApplyCount()
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.clear
        let abStr = NSMutableAttributedString(string: "详情...")
        abStr.addAttributes([NSUnderlineStyleAttributeName : 1 , NSForegroundColorAttributeName : UIColor.black , NSFontAttributeName : UIFont.systemFont(ofSize: 14)], range: NSMakeRange(0, 2))
        btnAdvertise.setAttributedTitle(abStr, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.handleGestureRecognizer(recognizer:)))
        
        vDetection.addGestureRecognizer(tap)
        
        lcRight.constant = (WIDTH - 240) / 4
        lcLeft.constant = (WIDTH - 240) / 4
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
    
    @IBAction func showAdvertiseDetail(_ sender: Any) {
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
        NetworkManager.sharedInstall.request(url: applyCount, params: params) {(json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["success"].boolValue {
                    
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
