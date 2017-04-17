//
//  RecordDetailViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/4/15.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON

class RecordDetailViewController: UIViewController {

    @IBOutlet weak var lblBillNo: UILabel!
    @IBOutlet weak var lblBillStatus: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    @IBOutlet weak var vAllSuggestion: UIView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lblOpinion: UILabel!
    var json : JSON!
    var statusInfo : [String : String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vContent.layer.borderWidth = 0.5
        vContent.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
        self.view.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
        vContent.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
        
        lblBillNo.text = json["carBillId"].string
        lblBillStatus.text = statusInfo["\(json["status"].int ?? 0)"]
        lblPrice.text = "\(json["evaluatePrice"].int ?? 0)"
        lblTime.text = json["createTime"].string
        lblRemark.text = json["mark"].string
        do {
            lblOpinion.attributedText = try NSAttributedString(data: json["applyAllOpinion"].stringValue.data(using: .unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        }catch{
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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