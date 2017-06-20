//
//  PreDetectionViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/6/17.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class PreDetectionViewController: UIViewController {

    @IBOutlet weak var vCommonPreDetection: UIView!
    @IBOutlet weak var vFastPreDetection: UIView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var lcLineWidth: NSLayoutConstraint!
    @IBOutlet weak var lcLineLeading: NSLayoutConstraint!
    @IBOutlet weak var lcCommonLeading: NSLayoutConstraint!
    @IBOutlet weak var lcFastTrailing: NSLayoutConstraint!
    @IBOutlet weak var ivLine: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        lcLineWidth.constant = WIDTH / 2
        lcCommonLeading.constant = (WIDTH - 160) / 3
        lcFastTrailing.constant = (WIDTH - 160) / 3
        
        segControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: .selected)
        segControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.gray], for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PreDetectionViewController.handleTap(sender:)))
        vCommonPreDetection.addGestureRecognizer(tap)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(PreDetectionViewController.handleTap(sender:)))
        vFastPreDetection.addGestureRecognizer(tap1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segSelectedIndex(_ sender: Any) {
        let index = segControl.selectedSegmentIndex
        lcLineLeading.constant = CGFloat(index) * (WIDTH / 2)
        UIView.animate(withDuration: 0.3, animations: { 
            [weak self] in
            self?.view.layoutIfNeeded()
        }) { (finished) in
            
        }
    }
    
    func handleTap(sender : Any) {
        if let recognizer = sender as? UITapGestureRecognizer {
            if recognizer.view == vCommonPreDetection {
                
            }else{
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "fastpredetection") as? FastPreDetectionViewController {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
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

}
