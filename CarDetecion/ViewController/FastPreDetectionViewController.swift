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

class FastPreDetectionViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , DetectionTableViewCellDelegate , UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var lcBottom: NSLayoutConstraint!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var tableView: UITableView!
    let sectionTitles = ["基础照片" , "补充照片" , "备注"]
    let titles = [["登记证首页" , "中控台含档位杆", "车左前45度"] , ["行驶证-正本\n副本同照", "左前门"]]
    let titlesImageClass = [["登记证" , "车辆内饰" , "车体骨架"] , ["行驶证" , "车身外观"]]
    var images : [Int : Data] = [:]
    var imagesPath = "" // 本地如果有缓冲图片，则读取图片
    var imagesFilePath = "" // 本地如果有缓冲图片，则读取图片
    let presentAnimator = PresentAnimator()
    let dismissAnimator = DismisssAnimator()
    let bill = "external/carBill/getCarBillIdNextVal.html"
    let upload = "external/app/uploadAppImage.html"
    let uploadPre = "external/app/addAppPreCarImage.html"
    let operationDesc = "external/source/operation-desc.json" // 水印和接口说明
    let billImages = "external/app/getAppBillImageList.html"
    let submitPre = "external/app/addPreCarBill.html"
    var orderNo = ""
    var remark = ""
    var bSubmit = false // 是否点击了提交
    var bSubmitSuccess = false // 是否提交成功
    var companyNo = 0 // 单位代号
    var nTag = 0 // 临时tag
    //var cameraType = 0 // 单拍，连拍
    var waterMarks : [JSON] = []
    let companyOtherNeed : [Int] = [0 , 100, 1 , 1000 , 1100]
    var source = 0  // 0 创建新的，1 未通过 ， 2 本地的
    var json : JSON? // 未通过时，获取的数据
    var arrImageInfo : [JSON] = []
    var pathName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FastPreDetectionViewController.handleNotification(notification:)), name: Notification.Name("detectionnew"), object: nil)
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
    
        tableView.register(UINib(nibName: "ReUseHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        getWaterMark(tag: -1)
            
        
        if imagesPath.characters.count > 0 {
            DispatchQueue.global().async {
                [weak self] in
                var images : [Int : Data] = [:]
                let array = self!.imagesPath.components(separatedBy: ",")
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                path = path! + "/\(self!.imagesFilePath)"
                for item in array {
                    if let image = UIImage(contentsOfFile: path! + "/\(item).jpg") {
                        images[Int(item)!] = UIImageJPEGRepresentation(image, 1)
                    }
                }
                self!.images = images
                DispatchQueue.main.async {
                    [weak self] in
                    self?.tableView.reloadData()
                }
            }
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
    
    // 通知处理
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : String] {
                    
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
        nTag = tag
        if let data = images[tag] {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(UIImage(data: data)!)// add some UIImage
            images.append(photo)
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayCloseButton = false
            let browser = SKPhotoBrowser(photos: images)
            let row = ((tag % 1000) % 100) * 2 + (tag % 1000 >= 100 ? 1 : 0)
            if row < titles[tag / 1000].count {
                browser.title = titles[tag / 1000][row]
            }else{
                browser.title = "添加图片"
            }
            browser.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "delete"), style: .plain, target: self, action: #selector(DetectionNewViewController.pop))
            self.navigationController?.pushViewController(browser, animated: true)
        }else{
            if waterMarks.count > 0{
                pushToCamera(tag: tag)
            }else{
                getWaterMark(tag: tag)
            }
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
        camera.companyNeed = companyOtherNeed
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
                tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: true)
            case 3:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .top, animated: true)
            case 4:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 5), at: .top, animated: true)
            case 5:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 6), at: .top, animated: true)
            default:
                fatalError()
            }
        }
    }
    
    // 保存
    @IBAction func save(_ sender: Any) {
        
    }
    
    // 显示提示框
    func showAlert(title : String?, message : String , button : String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .cancel, handler: {[weak self] (action) in
            if message == "保存成功" {
                self?.navigationController?.popViewController(animated: true)
            }
        }))
        present(alert, animated: true) {
            
        }
    }
    
    // 提交预评估订单
    @IBAction func submit(_ sender: Any) {
        tableView.endEditing(true) // 结束编辑
        bSubmit = true
        if !checkoutImage(companyNo: companyNo) {
            self.tableView.reloadData()
            showAlert(title: nil, message: "您还有内容尚未录入，是否返回继续编辑？" , button:"继续编辑")
            return
        }
        if source == 1 && images.count == 0 {
            showAlert(title: nil, message: "您没有做任何图片修改，无法提交！" , button:"确定")
            return
        }

        if source == 1 {
            orderNo = json?["carBillId"].string ?? ""
            if orderNo.characters.count > 0 {
                for (key , value) in self.images {
                    upLoadCount = self.images.count
                    let section = key / 1000
                    let row = (key % 1000) % 100
                    let right = key % 1000 >= 100
                    self.uploadImage(imageClass: self.titlesImageClass[section][row + (right ? 1 : 0)], imageSeqNum: row * 2 + (right ? 1 : 0), data: value)
                }

                self.navigationController?.popViewController(animated: true)
            }
        }else{
            
            let username = UserDefaults.standard.string(forKey: "username")
            var params = ["createUser" : username!]
            params["carBillType"] = "routine"
            params["mark"] = remark
            params["clientName"] = "iOS"
            let hud = self.showHUD(text: "提交中...")
            NetworkManager.sharedInstall.request(url: submitPre, params: params) {[weak self] (json, error) in
                self?.hideHUD(hud: hud)
                if error != nil {
                    print(error!.localizedDescription)
                }else{
                    if let data = json , data["success"].boolValue {
                        Toast(text: "提交成功").show()
                        self?.navigationController?.popViewController(animated: true)
                        self!.orderNo = "\(data["object"].int ?? 0)"
                        if self!.orderNo != "0" {
                            for (key , value) in self!.images {
                                upLoadCount = self!.images.count
                                let section = key / 1000
                                let row = (key % 1000) % 100
                                let right = key % 1000 >= 100
                                self!.uploadImage(imageClass: self!.titlesImageClass[section][row + (right ? 1 : 0)], imageSeqNum: row * 2 + (right ? 1 : 0), data: value)
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
    }
    
    // 上传图片
    func uploadImage(imageClass : String , imageSeqNum : Int , data : Data) {
        print("上传图片：\(imageClass)---\(imageSeqNum)")
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["createUser" : username!]
        params["clientName"] = "iOS"
        params["carBillId"] = orderNo
        params["imageClass"] = imageClass
        params["imageSeqNum"] = "\(imageSeqNum)"
        NetworkManager.sharedInstall.upload(url: uploadPre, params: params, data: data) {[weak self] (json, error) in
            DispatchQueue.global().async {
                if json?["success"].boolValue == true {
                    upLoadCount -= 1
                    if upLoadCount == 0 {
                    }
                }else{
                    print("上传失败:\(imageClass)---\(imageSeqNum)")
                    self?.uploadImage(imageClass: imageClass, imageSeqNum: imageSeqNum, data: data)
                }
            }
        }
        
        
    }
    
    // 获取水印
    func getWaterMark(tag : Int) {
        weak var hud : MBProgressHUD?
        if tag >= 0 {
            hud = showHUD(text: "加载中...")
        }
        NetworkManager.sharedInstall.requestString(url: operationDesc, params: nil) {[weak self] (json, error) in
            if hud != nil {
                self?.hideHUD(hud: hud!)
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
        if source != 1 {
            if images.count > 0 {
                if companyNo == 0 {
                    let keys = Set<Int>(images.keys)
                    if Set(companyOtherNeed).isSubset(of: keys) {
                        return true
                    }else{
                        return false
                    }
                }
            }
            return false
        }else{
            return true
        }
    }
    
    // MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 2 {
            let count = titles[section].count
            return (count % 2 > 0) ? (count / 2 + 1) : (count / 2)
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetectionTableViewCell
            cell.vCamera1.layer.cornerRadius = 6.0
            cell.vCamera2.layer.cornerRadius = 6.0
            cell.iv1.layer.cornerRadius = 6.0
            cell.iv2.layer.cornerRadius = 6.0
            cell.iv1.clipsToBounds = true
            cell.iv2.clipsToBounds = true
            cell.lbl11.layer.cornerRadius = 3.0
            cell.lbl22.layer.cornerRadius = 3.0
            cell.indexPath = indexPath
            cell.delegate = self
            cell.source = source
            let c = titles[indexPath.section].count
            let count = titles[indexPath.section].count
            if count % 2 > 0 && indexPath.row == count / 2 {
                cell.vCamera2.isHidden = true
            }else{
                cell.vCamera2.isHidden = false
            }
            if indexPath.row * 2 < c {
                cell.lbl1.text = titles[indexPath.section][indexPath.row * 2]
                cell.lbl11.text = titles[indexPath.section][indexPath.row * 2]
            }
            if indexPath.row * 2 + 1 < c {
                cell.lbl2.text = titles[indexPath.section][(indexPath.row * 2 + 1) % titles[indexPath.section].count]
                cell.lbl22.text = titles[indexPath.section][(indexPath.row * 2 + 1) % titles[indexPath.section].count]
            }
            cell.iv11.image = UIImage(named: indexPath.row * 2 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.iv21.image = UIImage(named: indexPath.row * 2 + 1 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.vCamera1.layer.borderWidth = 0.5
            cell.vCamera2.layer.borderWidth = 0.5
            if source == 1 {
                var bTem = false
                if images.count > 0 {
                    if let data = images[indexPath.section * 1000 + indexPath.row] {
                        cell.iv1.image = UIImage(data: data)
                        bTem = true
                    }
                }
                if !bTem {
                    for  json in arrImageInfo {
                        if json["imageClass"].string == sectionTitles[indexPath.section] {
                            if json["imageSeqNum"].intValue == indexPath.row * 2 {
                                cell.iv1.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                                bTem = true
                            }
                        }
                    }
                }
                if bTem {
                    cell.lbl11.isHidden = false
                    cell.lbl1.isHidden = true
                    cell.iv11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv1.image = nil
                    cell.lbl1.isHidden = false
                    cell.iv11.isHidden = false
                    cell.lbl11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }
                
            }else {
                if let data = images[indexPath.section * 1000 + indexPath.row] {
                    cell.iv1.image = UIImage(data: data)
                    cell.lbl11.isHidden = false
                    cell.lbl1.isHidden = true
                    cell.iv11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv1.image = nil
                    cell.lbl1.isHidden = false
                    cell.lbl11.isHidden = true
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
                if images.count > 0 {
                    if let data = images[indexPath.section * 1000 + indexPath.row + 100] {
                        cell.iv2.image = UIImage(data: data)
                        bTem = true
                    }
                }
                if !bTem {
                    for  json in arrImageInfo {
                        if json["imageClass"].string == sectionTitles[indexPath.section] {
                            if json["imageSeqNum"].intValue == indexPath.row * 2 + 1 {
                                cell.iv2.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                                bTem = true
                            }
                        }
                    }
                }
                if bTem {
                    cell.lbl2.isHidden = true
                    cell.lbl22.isHidden = false
                    cell.iv21.isHidden = true
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv2.image = nil
                    cell.lbl2.isHidden = false
                    cell.lbl22.isHidden = true
                    cell.iv21.isHidden = false
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }
                
            }else{
                if let data = images[indexPath.section * 1000 + indexPath.row + 100] {
                    cell.iv2.image = UIImage(data: data)
                    cell.lbl2.isHidden = true
                    cell.lbl22.isHidden = false
                    cell.iv21.isHidden = true
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv2.image = nil
                    cell.lbl2.isHidden = false
                    cell.lbl22.isHidden = true
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
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! Detection2TableViewCell
            cell.contentView.layer.borderWidth = 0.5
            if source == 1 {
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                cell.tvMark.text = json?["mark"].string
            }else if remark.characters.count == 0 && bSubmit {
                cell.contentView.layer.borderColor = UIColor.red.cgColor
            }else{
                if remark.characters.count > 0 {
                    cell.tvMark.text = remark
                }
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < 2 {
            return 10 + (WIDTH / 2 - 15) / 3 * 2.0
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

