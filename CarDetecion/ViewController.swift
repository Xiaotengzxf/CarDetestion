//
//  ViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 244 + WIDTH * 350 / 1080.0)
        addBannerView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addBannerView() -> Void {
        let banner = KCScrollingDisplayView(frame: CGRect(x: 0, y: WIDTH * 350 / 1080.0, width: WIDTH, height: 200))
        banner.pageControlAliment = .right
        banner.scrollDirection = .vertical
        banner.autoScrollTimeInterval = 5.0
        banner.titleArr = ["感谢您的支持，如果下载的","如果代码在使用过程中出现问题","您可以在GitHub上联系我"]
        banner.imageUrlArr = ["https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                              "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                              "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"]
        banner.clickCurrentIndexItemCallback = {
            (currentIndex: Int) in
            print(String(format: "点击了%d", currentIndex))
        }
        
        tableView.tableHeaderView?.addSubview(banner)
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

