//
//  DetectionNewViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/11.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class DetectionNewViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let sectionTitles = ["登记证" , "行驶证" , "铭牌" , "车身外观" , "车体骨架" , "车辆内饰" , "估价" , "备注"]
    let titles = [["登记证首页" , "登记证-车辆信息记录"] , ["行驶证-正本／副本同照"] , ["车辆铭牌"] , ["车左前45度" , "前档风玻璃" , "车右后45度" , "后档风玻璃"] , ["发动机盖" , "右侧内轨" , "右侧水箱支架" , "左侧内轨" , "左侧水箱支架" , "左前门" , "左前门铰链" , "左后门" , "行李箱左侧" , "行李箱右侧" , "行李箱左后底板" , "行李箱右后底板" , "右后门" , "右前门"] ,["方向盘及仪表" , "中央控制面板" , "中控台含挡位杆" , "后出风口"]]
    var images : [[NSData]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ReUseHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 6 {
            var count = titles[section].count + 1
            if images.count > section {
                count = max(count, images[section].count)
            }
            return (count % 2 > 0) ? (count / 2 + 1) : (count / 2)
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var count = titles[indexPath.section].count + 1
            if images.count > indexPath.section {
                count = max(count, images[indexPath.section].count)
            }
            if let view = cell.viewWithTag(5) {
                if count % 2 > 0 && indexPath.row == count / 2 {
                    view.isHidden = true
                }else{
                    view.isHidden = false
                }
            }
            if let label = cell.viewWithTag(2) as? UILabel {
                if indexPath.row * 2 < count - 1 {
                    label.text = titles[indexPath.section][indexPath.row * 2]
                }else{
                    label.text = "添加照片"
                }
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                if indexPath.row * 2 + 1 < count - 1 {
                    label.text = titles[indexPath.section][(indexPath.row * 2 + 1) % titles[indexPath.section].count]
                }else{
                    label.text = "添加照片"
                }
                
            }
            if let imageView = cell.viewWithTag(10) as? UIImageView {
                imageView.image = UIImage(named: indexPath.row * 2 < count - 1 ? "icon_camera" : "icon_add_photo")
            }
            if let imageView = cell.viewWithTag(11) as? UIImageView {
                imageView.image = UIImage(named: indexPath.row * 2 + 1 < count - 1 ? "icon_camera" : "icon_add_photo")
            }
            
            return cell
        }else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            if let view = cell.viewWithTag(5) {
                view.isHidden = true
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < 6 {
            return 10 + (WIDTH / 2 - 15) / 3 * 2.0
        }else if indexPath.section == 6 {
            return 44
        }else{
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! ReUseHeaderFooterView
        view.lblTitle.text = sectionTitles[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /*let camera = CameraViewController(croppingEnabled: false, allowsLibraryAccess: true) {[weak self] (image, asset) in
         self?.dismiss(animated: true, completion: {
         
         })
         }
         present(camera, animated: true) {
         
         }*/
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
