//
//  DetectionTableViewCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/30.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class DetectionTableViewCell: UITableViewCell {

    @IBOutlet weak var vCamera1: UIView!
    @IBOutlet weak var vCamera2: UIView!
    var tap1 : UITapGestureRecognizer?
    var tap2 : UITapGestureRecognizer?
    var indexPath : IndexPath!
    var delegate : DetectionTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awakeFromNib")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        vCamera1.tag = indexPath.section * 1000 + indexPath.row
        vCamera2.tag = indexPath.section * 1000 + indexPath.row + 100
        if tap1 == nil {
            tap1 = UITapGestureRecognizer(target: self, action: #selector(DetectionTableViewCell.handleGestureRecognizer(recognizer:)))
            vCamera1.addGestureRecognizer(tap1!)
        }
        if tap2 == nil {
            tap2 = UITapGestureRecognizer(target: self, action: #selector(DetectionTableViewCell.handleGestureRecognizer(recognizer:)))
            vCamera2.addGestureRecognizer(tap2!)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handleGestureRecognizer(recognizer : UITapGestureRecognizer)  {
        delegate?.cameraModel(tag: recognizer.view?.tag ?? 0)
    }

}

protocol DetectionTableViewCellDelegate {
    func cameraModel(tag : Int)
}
