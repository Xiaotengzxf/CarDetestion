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
    let sectionTitles = ["车型图" , "证件照(最少上传两张)" , "附加" , "估价" , "备注"]
    let titles = [["车辆左前45度" , "前档玻璃\n(生产日期)" , "左前门" , "仪表" , "左后门" , "中控台" , "内车顶" , "中央扶手" , "左后铰链" , "左后底板" , "右后底板" , "后台铰链" , "后档玻璃\n(生产日期)" , "车辆右后45度" , "右后门" , "右前门" , "右前水箱框架" , "右避震器座" , "左前水箱框架" , "左避震器座" , "铭牌"] , ["登记证"] , ["附件"]]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        if section == 0 {
            let count = titles[0].count
            return (count % 2 > 0) ? (count / 2 + 1) : (count / 2)
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let view = cell.viewWithTag(5) {
                let count = titles[0].count
                if count % 2 > 0 && indexPath.row == count / 2 {
                    view.isHidden = true
                }else{
                    view.isHidden = false
                }
            }
            if let label = cell.viewWithTag(2) as? UILabel {
                label.text = titles[0][indexPath.row * 2]
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                label.text = titles[0][(indexPath.row * 2 + 1) % titles[0].count]
            }
            return cell
        }else if indexPath.section == 3 {
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
        if indexPath.section < 3 {
            return 10 + (WIDTH / 2 - 15) / 3 * 2.0
        }else if indexPath.section == 3 {
            return 44
        }else{
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
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
