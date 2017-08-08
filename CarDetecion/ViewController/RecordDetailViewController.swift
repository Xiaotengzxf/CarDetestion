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

    @IBOutlet weak var lcTop: NSLayoutConstraint!
    @IBOutlet weak var lblPriceTip: UILabel!
    @IBOutlet weak var lblBillNo: UILabel!
    @IBOutlet weak var lblBillStatus: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    @IBOutlet weak var vAllSuggestion: UIView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lblOpinion: UILabel!
    @IBOutlet weak var vZuLin: UIView!
    @IBOutlet weak var lblLeaseTerm: UILabel!
    @IBOutlet weak var lblLeasePrice: UILabel!
    @IBOutlet weak var lcPriceTop: NSLayoutConstraint!
    var json : JSON!
    var statusInfo : [String : String]!
    var flag = 0
    
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
            var strOpinion = json["applyAllOpinion"].stringValue
            strOpinion = htmlStringToHtml5(htmlString: strOpinion)
            lblOpinion.attributedText = try NSAttributedString(data: strOpinion.data(using: .unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        }catch{
            
        }
        if flag == 1 {
            lblPrice.isHidden = true
            lblPriceTip.isHidden = true
            let leaseTerm = json["leaseTerm"].int ?? 0
            let residualPrice = json["residualPrice"].int ?? 0
            if leaseTerm == 0 {
                vZuLin.isHidden = true
                lcTop.constant = 5-59-20-10
            }else{
                lblLeaseTerm.text = "\(leaseTerm)月"
                lblLeasePrice.text = "\(residualPrice)元"
                lcPriceTop.constant = -25
            }
        }else{
            let leaseTerm = json["leaseTerm"].int ?? 0
            let residualPrice = json["residualPrice"].int ?? 0
            if leaseTerm == 0 {
                vZuLin.isHidden = true
                lcTop.constant = 5-59
            }else{
                lblLeaseTerm.text = "\(leaseTerm)月"
                lblLeasePrice.text = "\(residualPrice)元"
            }
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
    
    func htmlStringToHtml5(htmlString : String) -> String {
        return "<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,user-scalable=no\"></head><body>\(htmlString)</body></html>"
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
