//
//  DefaultViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/4/5.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class DefaultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.perform(#selector(DefaultViewController.changeWindowRoot), with: nil, afterDelay: 3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeWindowRoot() {
        if let tab = self.storyboard?.instantiateViewController(withIdentifier: "tab") {
            self.view.window?.rootViewController = tab
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
