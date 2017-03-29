//
//  LoginViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/29.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPwd: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    let login = "external/checkUser.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnLogin.layer.cornerRadius = 6.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 登录
    /*{
     "message" : "密码错误",
     "object" : null,
     "success" : false
     }*/
    @IBAction func loginIn(_ sender: Any) {
        tfUserName.resignFirstResponder()
        tfPwd.resignFirstResponder()
        guard let username = tfUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) , username.characters.count > 0 else {
            Toast(text: "请输入用户名").show()
            return
        }
        guard let pwd = tfPwd.text?.trimmingCharacters(in: .whitespacesAndNewlines) , pwd.characters.count > 0 else {
            Toast(text: "请输入密码").show()
            return
        }
        let hud = self.showHUD(text: "登录中...")
        NetworkManager.sharedInstall.request(url: login, params: ["userName" : username , "password" : pwd]) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                Toast(text: "网络故障，请检查网络").show()
            }else{
                if let data = json , data["success"].boolValue {
                    if let tab = self?.storyboard?.instantiateViewController(withIdentifier: "tab") {
                        UserDefaults.standard.set(username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        self?.view.window?.rootViewController = tab
                    }
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
