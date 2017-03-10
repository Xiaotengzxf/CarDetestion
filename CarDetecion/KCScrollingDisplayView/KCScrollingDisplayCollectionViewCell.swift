//
//  KCScrollingDisplayCollectionViewCell.swift
//  KevinClient
//
//  Created by Kevin on 2017/3/8.
//  Copyright © 2017年 KevinClient.,Ltd. All rights reserved.
//

import UIKit

class KCScrollingDisplayCollectionViewCell: UICollectionViewCell {
    
    /// 是否只显示文字
    var isOnlyShowText: Bool = false
    var titleLabelHeight: CGFloat = 30.0
    var title: String? {

        didSet {
            if let title = title {
                if title.characters.count > 0 {
                    titleLabel.isHidden = false
                    titleLabel.text = "   \(title)"
                }
                else {
                    titleLabel.isHidden = true
                }
            }
        }
    }
    
    
    lazy var bannerImageView: UIImageView = {
        let bannerImageView = UIImageView(frame: self.contentView.bounds)
        return bannerImageView
    }()
    
    lazy var titleLabel: UILabel = {
        
        let titleLabel = UILabel()
        return titleLabel
    }()
    /// 用于标记cell是否已配置相关属性
    var isHasConfigured = false
    
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bannerImageView)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isOnlyShowText == true {
            titleLabel.frame = self.contentView.bounds
        }
        else {
            
            let width = self.contentView.bounds.size.width
            let height = titleLabelHeight
            let x: CGFloat = 0
            let y = self.contentView.bounds.size.height - height
            titleLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
}
