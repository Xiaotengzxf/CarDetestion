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
    @IBOutlet weak var ivTriangle: UIImageView!
    let login = "external/checkUser.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //btnLogin.layer.cornerRadius = 6.0
        ivTriangle.image = drawTriangle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawTriangle() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 5), false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.beginPath()
        ctx?.move(to: CGPoint(x: 5, y: 0))
        ctx?.addLine(to: CGPoint(x: 10, y: 5))
        ctx?.addLine(to: CGPoint(x: 0, y: 5))
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.closePath()
        ctx?.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.synchronize()
                    if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "default") as? DefaultViewController {
                        controller.modalTransitionStyle = .crossDissolve
                        self?.present(controller, animated: true, completion: { 
                            
                        })
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
