//
//  CarModelCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/2.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class CarModelCell: UITableViewCell {

    @IBOutlet weak var lblCar: UILabel!
    @IBOutlet weak var lcRight: NSLayoutConstraint!
    @IBOutlet weak var lcLeft: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
