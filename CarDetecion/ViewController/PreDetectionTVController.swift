//
//  PreDetectionTVController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/1.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class PreDetectionTVController: UITableViewController {
    
    var arrIcon = ["icon_pinpai", "icon_licheng", "icon_shijian", "icon_licheng", "icon_weizhi"]
    var arrTitle = ["品牌车型", "车颜色", "上牌时间", "行驶里程", "选择城市", "备注输入"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 64)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PreDetectionCell
        if indexPath.row < 5 {
            cell.ivIcon.image = UIImage(named: arrIcon[indexPath.row])
        }else{
            cell.ivIcon.image = nil
        }
        cell.lblTitle.text = arrTitle[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.ivArrow.isHidden = false
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = false
            cell.tvContent.isHidden = true
            cell.lblContent.text = "请选择品牌车型"
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 30
            cell.lcIconHeight.constant = 22
        case 1:
            cell.ivArrow.isHidden = true
            cell.tfContent.isHidden = false
            cell.lblContent.isHidden = true
            cell.tvContent.isHidden = true
            cell.tfContent.placeholder = "请输入车颜色"
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 28
            cell.lcIconHeight.constant = 24
        case 2:
            cell.ivArrow.isHidden = false
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = false
            cell.tvContent.isHidden = true
            cell.lblContent.text = "请选择上牌时间"
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 35
            cell.lcIconHeight.constant = 31
        case 3:
            cell.ivArrow.isHidden = true
            cell.tfContent.isHidden = false
            cell.lblContent.isHidden = true
            cell.tvContent.isHidden = true
            cell.tfContent.placeholder = "请输入"
            let label = UILabel()
            label.text = "公里"
            if cell.tfContent.rightView == nil {
                cell.tfContent.rightView = label
            }
            cell.lcIconWidth.constant = 28
            cell.lcIconHeight.constant = 24
        case 4:
            cell.ivArrow.isHidden = false
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = false
            cell.tvContent.isHidden = true
            cell.lblContent.text = "请选择上牌城市"
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 30
            cell.lcIconHeight.constant = 37
        default:
            cell.ivArrow.isHidden = true
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = true
            cell.tvContent.isHidden = false
            cell.tfContent.rightView = nil
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 {
            return 100
        }else{
            return 60
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
