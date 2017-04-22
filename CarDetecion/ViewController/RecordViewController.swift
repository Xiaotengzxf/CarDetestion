//
//  RecordTableViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
import Toaster
import DZNEmptyDataSet
import SDWebImage

class RecordViewController: UIViewController , DZNEmptyDataSetDelegate , DZNEmptyDataSetSource , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var ivDivide: UIImageView!
    @IBOutlet weak var lcDivideLeft: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    let orderList = "external/app/getAppBillList.html"
    var curPage = 1
    var status = ""
    let pageSize = 10
    var data : [JSON] = []
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络
    var statusInfo : [String : String] = ["21": "等待初审" , "22": "初审中" , "23": "初审驳回" , "24": "初审通过",
                      "31": "等待初评" , "32": "初评中" , "33": "初评驳回" , "34": "初评通过",
                      "41": "等待中评" , "42": "中评中" , "43": "中评驳回" , "44": "中评通过",
                      "51": "等待高评" , "52": "高评中" , "53": "高评驳回" , "54": "高评通过",
                      "80": "评估完成"] // 0, "提取图片"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 44)
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.darkGray], for: .normal)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: .selected)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.curPage = 1
            self?.getBillList()
        })
        
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { 
            [weak self] in
            self?.curPage += 1
            self?.getBillList()
        })
        tableView.mj_footer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if recordIndex >= 0 {
            segmentedControl.selectedSegmentIndex = recordIndex
            changeSegmentControl(segmentedControl)
            recordIndex = -1
        }else{
            if segmentedControl.selectedSegmentIndex == 0 {
                data.removeAll()
                if let orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
                    if orders.count > 0 {
                        for dic in orders {
                            data.append(JSON(dic))
                        }
                    }
                }
                if data.count == 0 {
                    nShowEmpty = 1
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBillList() {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        params["curPage"] = "\(curPage)"
        params["pageSize"] = "\(pageSize)"
        params["status"] = status
        NetworkManager.sharedInstall.request(url: orderList, params: params) {[weak self] (json, error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
                if self!.curPage == 1 {
                    self?.nShowEmpty = 3
                    self?.tableView.reloadData()
                }
            }else{
                if self!.curPage == 1 {
                    self!.data.removeAll()
                }
                if let total = json?["total"].intValue , total > 0 {
                    if let array = json?["data"].array {
                        self?.data += array
                    }
                    if self!.data.count > 0 {
                        self?.tableView.mj_footer.isHidden = false
                    }else{
                        self?.tableView.mj_footer.isHidden = true
                    }
                    if total < self!.pageSize {
                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }
                    if self!.curPage == 1 && self!.data.count == 0 {
                        self?.nShowEmpty = 1
                    }
                }else{
                    if self!.curPage == 1 && self!.data.count == 0 {
                        self?.nShowEmpty = 1
                    }
                }
                self?.tableView.reloadData()
            }
        }
    }

    @IBAction func changeSegmentControl(_ sender: Any) {
        lcDivideLeft.constant = segmentedControl.bounds.width / 4 * CGFloat(segmentedControl.selectedSegmentIndex)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            data.removeAll()
            if let orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
                if orders.count > 0 {
                    for dic in orders {
                        data.append(JSON(dic))
                    }
                }
            }
            if data.count == 0 {
                nShowEmpty = 1
            }
            self.tableView.reloadData()
            return
        case 1:
            status = "21,22,24,31,32,34,41,42,44,51,52"
        case 2:
            status = "23,33,43,53"
        case 3:
            status = "54,80"
        default:
            status = "0"
        }
        if nShowEmpty != 0 {
            nShowEmpty = 0
            self.tableView.reloadData()
        }
        tableView.mj_header.beginRefreshing()
    }
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if segmentedControl.selectedSegmentIndex == 0 {
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = "暂无单号"
            }
            if let label = cell.contentView.viewWithTag(4) as? UILabel {
                label.text = "添加时间：\(data[indexPath.row]["addtime"].string ?? "") "
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                label.text = ""
            }
            if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
                imageView.image = UIImage(named: "defult_image")
            }
        }else{
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = "单号：\(data[indexPath.row]["carBillId"].string ?? "")"
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                if segmentedControl.selectedSegmentIndex == 1 {
                    label.text = "审核进度：\(statusInfo["\(data[indexPath.row]["status"].int ?? 0)"]!)"
                    label.textColor = UIColor.rgbColorFromHex(rgb: 0xF86765)
                }else{
                    label.text = "创建时间：\(data[indexPath.row]["createTime"].string ?? "")"
                    label.textColor = UIColor.darkGray
                }
                
            }
            if let label = cell.contentView.viewWithTag(4) as? UILabel {
                if segmentedControl.selectedSegmentIndex == 1 {
                    label.text = "创建时间：\(data[indexPath.row]["createTime"].string ?? "")"
                    label.textColor = UIColor.darkGray
                }else if segmentedControl.selectedSegmentIndex == 2 {
                    label.text = "退回时间：\(data[indexPath.row]["createTime"].string ?? "")"
                    label.textColor = UIColor.rgbColorFromHex(rgb: 0xF86765)
                }else{
                    label.text = "评估价格：\(data[indexPath.row]["evaluatePrice"].int ?? 0) "
                    label.textColor = UIColor.rgbColorFromHex(rgb: 0x2e8b57)
                }
            }
            if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
                let imagePath = data[indexPath.row]["imageThumbPath"].string ?? ""
                if imagePath.characters.count > 0 {
                    imageView.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(imagePath)"), placeholderImage: UIImage(named: "defult_image"))
                }else{
                    imageView.image = UIImage(named: "defult_image")
                }
                
            }
        }

        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if  segmentedControl.selectedSegmentIndex == 0 {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
                let json = data[indexPath.row]
                var orderKeys : [String] = []
                if let keys = UserDefaults.standard.object(forKey: "orderKeys") as? [String] {
                    orderKeys += keys
                }
                if let urls = json["images"].string {
                    var images : [Int : Data] = [:]
                    let array = urls.components(separatedBy: ",")
                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                    path = path! + "/\(orderKeys[indexPath.row])"
                    for item in array {
                        if let image = UIImage(contentsOfFile: path! + "/\(item).jpg") {
                            images[Int(item)!] = UIImageJPEGRepresentation(image, 1)
                        }
                    }
                    
                    controller.pathName = orderKeys[indexPath.row]
                    controller.images = images
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }else{
            if segmentedControl.selectedSegmentIndex == 2 {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
                    controller.source = 1
                    controller.json = data[indexPath.row]
                    controller.title = "已退回-\(data[indexPath.row]["carBillId"].string ?? "")"
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }else{
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "recorddetail") as? RecordDetailViewController {
                    controller.json = data[indexPath.row]
                    controller.statusInfo = statusInfo
                    controller.flag = segmentedControl.selectedSegmentIndex
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if segmentedControl.selectedSegmentIndex == 0 {
            return "删除"
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }else{
            
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
    
    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ad_empty")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = ""
        if nShowEmpty == 1 {
            message = "空空如也，啥子都没有噢！"
        }else if nShowEmpty == 2 {
            message = "加载是件正经事儿，走心加载中..."
        }else if nShowEmpty == 3 {
            message = "世界上最遥远的距离就是没有网络..."
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if nShowEmpty > 0 && segmentedControl.selectedSegmentIndex != 0 {
            nShowEmpty = 0
            tableView.reloadData()
            tableView.mj_header.beginRefreshing()
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty > 0
    }

}
