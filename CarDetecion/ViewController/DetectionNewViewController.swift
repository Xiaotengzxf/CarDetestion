//
//  DetectionNewViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/11.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import Toaster
import SKPhotoBrowser
import SwiftyJSON
import MBProgressHUD

class DetectionNewViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , DetectionTableViewCellDelegate , UIViewControllerTransitioningDelegate {

    @IBOutlet weak var lcBottom: NSLayoutConstraint!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var tableView: UITableView!
    let sectionTitles = ["登记证" , "行驶证" , "铭牌" , "车身外观" , "车体骨架" , "车辆内饰" , "估价" , "备注"]
    let titles = [["登记证首页" , "登记证\n车辆信息记录"] , ["行驶证-正本\n副本同照"] , ["车辆铭牌"] , ["车左前45度" , "前档风玻璃" , "车右后45度" , "后档风玻璃"] , ["发动机盖" , "右侧内轨" , "右侧水箱支架" , "左侧内轨" , "左侧水箱支架" , "左前门" , "左前门铰链" , "左后门" , "行李箱左侧" , "行李箱右侧" , "行李箱左后底板" , "行李箱右后底板" , "右后门" , "右前门"] ,["方向盘及仪表" , "中央控制面板" , "中控台含挡位杆" , "后出风口"]]
    var images : [Int : Data] = [:]
    let presentAnimator = PresentAnimator()
    let dismissAnimator = DismisssAnimator()
    let bill = "external/carBill/getCarBillIdNextVal.html"
    let upload = "external/app/uploadAppImage.html"
    let operationDesc = "external/source/operation-desc.json" // 水印和接口说明
    let billImages = "external/app/getAppBillImageList.html"
    var orderNo = ""
    var price = ""
    var remark = ""
    var bSubmit = false // 是否点击了提交
    var companyNo = 0 // 单位代号
    var nTag = 0 // 临时tag
    //var cameraType = 0 // 单拍，连拍
    var waterMarks : [JSON] = []
    let companyOtherNeed : Set<Int> = [0 , 100 , 1000 , 2000 , 3000 , 3100 , 3001 , 3101 , 4000 , 4100 , 4001 , 4101 , 4002 , 4102 , 4003 , 4103 , 4004 , 4104 , 4005 , 4105 , 4006 , 4106 , 5000 , 5100 , 5001 , 5101]
    var source = 0  // 0 创建新的，1 未通过 ， 2 本地的
    var json : JSON? // 未通过时，获取的数据
    var arrImageInfo : [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ReUseHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        NotificationCenter.default.addObserver(self, selector: #selector(DetectionNewViewController.handleNotification(notification:)), name: Notification.Name("detectionnew"), object: nil)
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        if source == 1 {
            loadUnpassData()
            vBottom.isHidden = true
            lcBottom.constant = 0
            if let label = tableView.tableHeaderView?.viewWithTag(10000) as? UILabel {
                do {
                    label.attributedText = try NSAttributedString(data: "退回原因：\(json?["applyAllOpinion"].string ?? "")".data(using: .unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                }catch{
                    
                }
            }
        }else {
            tableView.tableHeaderView = nil
            getWaterMark(tag: -1)
            
//            let barButton = UIBarButtonItem(title: "单拍", style: .plain, target: self, action: #selector(DetectionNewViewController.setCameraType))
//            self.navigationItem.rightBarButtonItem = barButton
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadUnpassData() {
        let hud = showHUD(text: "加载中...")
        let username = UserDefaults.standard.string(forKey: "username")
        let params = ["userName" : username!, "carBillId": json!["carBillId"].stringValue]
        NetworkManager.sharedInstall.request(url: billImages, params: params) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        self?.arrImageInfo += array
                        self?.tableView.reloadData()
                    }
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    
    // 拍照类型
//    func setCameraType() {
//        let action = UIAlertController(title: "拍照类型", message: nil, preferredStyle: .actionSheet)
//        action.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
//            
//        }))
//        action.addAction(UIAlertAction(title: "单拍", style: .default, handler: {[weak self] (action) in
//            self?.cameraType = 0
//        }))
//        action.addAction(UIAlertAction(title: "连拍", style: .default, handler: {[weak self] (action) in
//            self?.cameraType = 1
//        }))
//    }
    
    // 通知处理
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : String] {
                    price = userInfo["text"]!
                }
            }else if tag == 2 {
                if let userInfo = notification.userInfo as? [String : String] {
                    remark = userInfo["text"]!
                }
            }else if tag == 3 {
                if let userInfo = notification.userInfo as? [String : Int] {
                    nTag = userInfo["tag"]!
                }
            }
        }
    }
    
    // tableviewcell的拍照代理
    func cameraModel(tag: Int) {
        if source == 1 {
            return
        }
        nTag = tag
        if let data = images[tag] {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(UIImage(data: data)!)// add some UIImage
            images.append(photo)
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayCloseButton = false
            let browser = SKPhotoBrowser(photos: images)
            browser.title = titles[tag / 1000][((tag % 1000) % 100) * 2 + (tag % 1000 >= 100 ? 1 : 0)]
            browser.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "delete"), style: .plain, target: self, action: #selector(DetectionNewViewController.pop))
            self.navigationController?.pushViewController(browser, animated: true)
        }else{
            if waterMarks.count > 0{
                pushToCamera(tag: tag)
            }else{
                getWaterMark(tag: tag)
            }
//            if companyOtherNeed.contains(tag) {
//                if waterMarks.count > 0{
//                    pushToCamera(tag: tag)
//                }else{
//                    getWaterMark(tag: tag)
//                }
//            }else{
//                let section = tag / 1000
//                //let row = tag % 1000 % 100
//                //let right = tag % 100 >= 100
//                let array = companyOtherNeed.sorted()
//                for value in array {
//                    if value / 1000 == section {
//                        if value < tag {
//                            if images[value] == nil {
//                                self.showAlert(title: nil, message: "请先拍照：\(titles[value / 1000][((value % 1000) % 100) * 2 + (value % 1000 >= 100 ? 1 : 0)])" , button: "确定")
//                                return
//                            }
//                        }
//                    }
//                }
//            }
        }
        
    }
    
    // 跳转到拍照界面
    func pushToCamera(tag : Int) {
        
        nTag = tag
        let camera = CameraViewController(croppingEnabled: false, allowsLibraryAccess: true) {[weak self] (image, asset) in
            if image != nil {
                self?.images[self!.nTag] = UIImageJPEGRepresentation(image!, 0.2)!
                self?.tableView.reloadData()
            }
        }
        //camera.cameraType = cameraType
        camera.nTag = nTag
        camera.sectionTiltes = sectionTitles
        camera.titles = titles
        camera.waterMarks = waterMarks
        //camera.transitioningDelegate = self
        self.present(camera, animated: true) {
            
        }
    }
    
    // 弹框是否删除
    func pop() {
        let alert = UIAlertController(title: nil, message: "确认删除？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "删除", style: .default, handler: {[weak self] (action) in
            self!.images[self!.nTag] = nil
            self?.tableView.reloadData()
            _ = self?.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "不，保留", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true) { 
            
        }
    }

    @IBAction func move(_ sender: Any) {
        if let button = sender as? UIButton {
            switch button.tag {
            case 1:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            case 2:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
            case 3:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .top, animated: true)
            case 4:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 6), at: .top, animated: true)
            default:
                fatalError()
            }
        }
    }
    
    // 保存
    @IBAction func save(_ sender: Any) {
        if images.count > 0 || price.characters.count > 0 || remark.characters.count > 0 {
            var orders : [[String : String]] = []
            if let order = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
                orders += order
            }
            let fileManager = FileManager.default
            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            path = path! + "/\(orders.count + 1)"
            do{
                try fileManager.createDirectory(atPath:path! , withIntermediateDirectories: true, attributes: nil)
                var imageStr = ""
                for (key , value) in images {
                    imageStr += "\(key),"
                    let result = fileManager.createFile(atPath: path! + "/\(key).jpg", contents: value, attributes: nil)
                    if !result {
                        print("图片保存失败")
                    }
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                orders.append(["price" : price , "remark" : remark , "images" : imageStr.substring(from: imageStr.index(before: imageStr.endIndex)) , "addtime" : formatter.string(from: Date())])
                UserDefaults.standard.set(orders, forKey: "orders")
                UserDefaults.standard.synchronize()
                
                showAlert(title: "温馨提示", message: "保存成功", button: "确定")
                
            }catch{
                showAlert(title: "温馨提示", message: "保存失败，数据丢失!", button: "确定")
            }
        }else{
            showAlert(title: "温馨提示", message: "您没有拍摄任何照片，或输入价格，或输入内容！", button: "保存失败")
        }
    }
    
    // 显示提示框
    func showAlert(title : String?, message : String , button : String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .cancel, handler: { (action) in
            
        }))
        present(alert, animated: true) { 
            
        }
    }
    
    // 提交订单
    @IBAction func submit(_ sender: Any) {
        tableView.endEditing(true) // 结束编辑
        bSubmit = true
        if !checkoutImage(companyNo: companyNo) {
            self.tableView.reloadData()
            showAlert(title: nil, message: "您还有内容尚未录入，是否返回继续编辑？" , button:"继续编辑")
            return
        }
        if price.characters.count == 0 {
            Toast(text : "请输入预售价格").show()
            return
        }
        if remark.characters.count == 0 {
            Toast(text : "请输入备注").show()
            return
        }
        let hud = self.showHUD(text: "创建中...")
        NetworkManager.sharedInstall.request(url: bill, params: nil) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                Toast(text: "网络故障，请检查网络").show()
            }else{
                if let data = json {
                    self?.orderNo = data.stringValue
                    for (key , value) in self!.images {
                        upLoadCount = self!.images.count
                        let section = key / 1000
                        let row = (key % 1000) % 100
                        let right = key % 1000 >= 100
                        self?.uploadImage(imageClass: self!.sectionTitles[section], imageSeqNum: row * 2 + (right ? 1 : 0), data: value)
                    }
                    NotificationCenter.default.post(name: Notification.Name("app"), object: 1, userInfo: ["orderNo" : self!.orderNo , "price" : self!.price , "remark" : self!.remark])
                    self?.dismiss(animated: true, completion: { 
                        
                    })
                }
            }
        }
    }
    
    // 上传图片
    func uploadImage(imageClass : String , imageSeqNum : Int , data : Data) {
        
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["createUser" : username!]
        params["clientName"] = "iOS"
        params["carBillId"] = orderNo
        params["imageClass"] = imageClass
        params["imageSeqNum"] = "\(imageSeqNum)"
        NetworkManager.sharedInstall.upload(url: upload, params: params, data: data) { (json, error) in
            DispatchQueue.global().async {
                upLoadCount -= 1
                if upLoadCount == 0 {
                    NotificationCenter.default.post(name: Notification.Name("app"), object: 2 , userInfo: ["orderNo" : params["carBillId"]!])
                }
            }
        }
        
        
    }
    
    // 获取水印
    func getWaterMark(tag : Int) {
        var hud : MBProgressHUD?
        if tag >= 0 {
            hud = showHUD(text: "加载中...")
        }
        NetworkManager.sharedInstall.requestString(url: operationDesc, params: nil) {[weak self] (json, error) in
            if hud != nil {
                hud?.hide(animated: true)
            }
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json?["data"].array {
                    self?.waterMarks += data
                    if tag >= 0 {
                        self?.pushToCamera(tag: tag)
                    }
                }
            }
        }
    }
    
    // 检查公司必传的照片
    func checkoutImage(companyNo : Int) -> Bool {
        if images.count > 0 {
            if companyNo == 0 {
                let keys = Set<Int>(images.keys)
                if companyOtherNeed.isSubset(of: keys) {
                    return true
                }else{
                    return false
                }
            }
        }
        return false
    }
    
    // MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 6 {
            var count = titles[section].count + 1
            if images.count > 0 {
                let array = images.filter{$0.key >= section * 1000 && $0.key < (section + 1) * 1000}
                count = max(count, array.count)
            }
            return (count % 2 > 0) ? (count / 2 + 1) : (count / 2)
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetectionTableViewCell
            cell.vCamera1.layer.cornerRadius = 6.0
            cell.vCamera2.layer.cornerRadius = 6.0
            cell.iv1.layer.cornerRadius = 6.0
            cell.iv2.layer.cornerRadius = 6.0
            cell.iv1.clipsToBounds = true
            cell.iv2.clipsToBounds = true
            cell.lbl1.layer.cornerRadius = 3.0
            cell.lbl2.layer.cornerRadius = 3.0
            cell.indexPath = indexPath
            cell.delegate = self
            cell.source = source
            var count = titles[indexPath.section].count + 1
            if images.count > 0 {
                let array = images.filter{$0.key >= indexPath.section * 1000 && $0.key < (indexPath.section + 1) * 1000}
                count = max(count, array.count)
            }
            if count % 2 > 0 && indexPath.row == count / 2 {
                cell.vCamera2.isHidden = true
            }else{
                cell.vCamera2.isHidden = false
            }
            if indexPath.row * 2 < count - 1 {
                cell.lbl1.text = titles[indexPath.section][indexPath.row * 2]
            }else{
                cell.lbl1.text = "添加照片"
            }
            if indexPath.row * 2 + 1 < count - 1 {
                cell.lbl2.text = titles[indexPath.section][(indexPath.row * 2 + 1) % titles[indexPath.section].count]
            }else{
                cell.lbl2.text = "添加照片"
            }
            cell.iv11.image = UIImage(named: indexPath.row * 2 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.iv21.image = UIImage(named: indexPath.row * 2 + 1 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.vCamera1.layer.borderWidth = 0.5
            cell.vCamera2.layer.borderWidth = 0.5
            if source == 1 {
                var bTem = false
                for  json in arrImageInfo {
                    if json["imageClass"].string == sectionTitles[indexPath.section] {
                        if json["imageSeqNum"].intValue == indexPath.row * 2 {
                            cell.iv1.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                            bTem = true
                        }
                    }
                }
                if bTem {
                    cell.lbl1.textColor = UIColor.white
                    cell.lbl1.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    cell.iv11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv1.image = nil
                    cell.lbl1.textColor = UIColor(red: 107/255.0, green: 107/255.0, blue: 107/255.0, alpha: 1)
                    
                    cell.lbl1.backgroundColor = UIColor.clear
                    cell.iv11.isHidden = false
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }
                
            }else {
                if let data = images[indexPath.section * 1000 + indexPath.row] {
                    cell.iv1.image = UIImage(data: data)
                    cell.lbl1.textColor = UIColor.white
                    cell.lbl1.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    cell.iv11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv1.image = nil
                    cell.lbl1.textColor = UIColor(red: 107/255.0, green: 107/255.0, blue: 107/255.0, alpha: 1)
                    
                    cell.lbl1.backgroundColor = UIColor.clear
                    cell.iv11.isHidden = false
                    if bSubmit {
                        if companyNo == 0 {
                            if companyOtherNeed.contains(indexPath.section * 1000 + indexPath.row) {
                                cell.vCamera1.layer.borderColor = UIColor.red.cgColor
                            }else{
                                cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                            }
                        }else{
                            cell.vCamera1.layer.borderColor = UIColor.red.cgColor
                        }
                        
                    }else{
                        cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                    }
                }
            }
            if source == 1 {
                var bTem = false
                for  json in arrImageInfo {
                    if json["imageClass"].string == sectionTitles[indexPath.section] {
                        if json["imageSeqNum"].intValue == indexPath.row * 2 + 1 {
                            cell.iv2.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                            bTem = true
                        }
                    }
                }
                if bTem {
                    cell.lbl2.textColor = UIColor.white
                    cell.lbl2.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    cell.iv21.isHidden = true
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv2.image = nil
                    cell.lbl2.textColor = UIColor(red: 107/255.0, green: 107/255.0, blue: 107/255.0, alpha: 1)
                    cell.lbl2.backgroundColor = UIColor.clear
                    cell.iv21.isHidden = false
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }
                
            }else{
                if let data = images[indexPath.section * 1000 + indexPath.row + 100] {
                    cell.iv2.image = UIImage(data: data)
                    cell.lbl2.textColor = UIColor.white
                    cell.lbl2.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    cell.iv21.isHidden = true
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv2.image = nil
                    cell.lbl2.textColor = UIColor(red: 107/255.0, green: 107/255.0, blue: 107/255.0, alpha: 1)
                    cell.lbl2.backgroundColor = UIColor.clear
                    cell.iv21.isHidden = false
                    if bSubmit {
                        if companyNo == 0 {
                            if companyOtherNeed.contains(indexPath.section * 1000 + indexPath.row + 100) {
                                cell.vCamera2.layer.borderColor = UIColor.red.cgColor
                            }else{
                                cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                            }
                        }else{
                            cell.vCamera2.layer.borderColor = UIColor.red.cgColor
                        }
                    }else{
                        cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                    }
                }
            }
            
            return cell
        }else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! Detection1TableViewCell
            cell.contentView.layer.borderWidth = 0.5
            if source == 1 {
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                cell.tfPrice.text = json?["preSalePrice"].string
                cell.tfPrice.isUserInteractionEnabled = false
            }else if price.characters.count == 0 && bSubmit {
                cell.contentView.layer.borderColor = UIColor.red.cgColor
            }else{
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! Detection2TableViewCell
            cell.contentView.layer.borderWidth = 0.5
            if source == 1 {
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                cell.tvMark.text = json?["mark"].string
                cell.tvMark.isUserInteractionEnabled = false
            }else if remark.characters.count == 0 && bSubmit {
                cell.contentView.layer.borderColor = UIColor.red.cgColor
            }else{
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
            }
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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 转场动画
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
}
