//
//  ViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SDCycleScrollView

class MainViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , SDCycleScrollViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTotalCount: UILabel!
    
    let applyCount = "external/app/getApplyCountInfo.html"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 244 + 120)
        addBannerView()
        
        getApplyCount() // 获取总单量
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addBannerView() -> Void {
        let banner = SDCycleScrollView(frame: CGRect(x: 0, y: 120, width: WIDTH, height: 200), delegate: self, placeholderImage: nil)
        banner?.imageURLStringsGroup = ["https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                              "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                              "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"]
        tableView.tableHeaderView?.addSubview(banner!)
    }
    
    // 获取审核中，未通过及通过的订单总数
    func getApplyCount() {
        let username = UserDefaults.standard.string(forKey: "username")
        let params = ["userName" : username!]
        NetworkManager.sharedInstall.request(url: applyCount, params: params) {[weak self] (json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        var totalCount = 0
                        for j in array {
                            
                            if j["infoType"].stringValue == "finishCount" {
                                totalCount += j["countInfo"].int ?? 0
                            }else if j["infoType"].stringValue == "refuseCount" {
                                totalCount += j["countInfo"].int ?? 0
                            }else if j["infoType"].stringValue == "processCount" {
                                totalCount += j["countInfo"].int ?? 0
                            }
                        }
                        self?.lblTotalCount.text = "总单量：\(totalCount)"
                    }
                }
            }
        }
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }

}
