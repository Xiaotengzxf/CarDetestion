//
//  RecordTableViewCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/4/22.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    var longTap : UILongPressGestureRecognizer?
    var delegate : RecordTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addLongTap() {
        if longTap == nil {
            longTap = UILongPressGestureRecognizer(target: self, action: #selector(RecordTableViewCell.handleLongPress(longPress:)))
            self.addGestureRecognizer(longTap!)
        }
    }
    
    func handleLongPress(longPress : UILongPressGestureRecognizer) {
        delegate?.tapCell(tag: tag)
    }

}

protocol RecordTableViewCellDelegate {
    func tapCell(tag : Int)
}
