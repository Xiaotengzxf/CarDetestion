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

class RecordTableViewController: UITableViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var ivDivide: UIImageView!
    @IBOutlet weak var lcDivideLeft: NSLayoutConstraint!
    let orderList = "external/app/getAppBillList.html"
    var curPage = 0
    var status = ""
    let pageSize = 20
    let data : [JSON] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 44)
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.darkGray], for: .normal)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: .selected)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.curPage = 0
            self?.getBillList()
        })
        tableView.mj_header.beginRefreshing()
        
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { 
            [weak self] in
            self?.curPage += 1
            self?.getBillList()
        })
        tableView.mj_footer.isHidden = true
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
        params["status"] = ""
        NetworkManager.sharedInstall.request(url: orderList, params: params) {[weak self] (json, error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["success"].boolValue {
                    
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    
    
    

    @IBAction func changeSegmentControl(_ sender: Any) {
        lcDivideLeft.constant = segmentedControl.bounds.width / 4 * CGFloat(segmentedControl.selectedSegmentIndex)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            status = ""
        case 1:
            status = "21,22,24,31,32,34,41,42,44,51,52,54"
        case 2:
            status = "23,33,43,54"
        case 3:
            status = "80"
        default:
            status = "0"
        }
        tableView.mj_header.beginRefreshing()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
