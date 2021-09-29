//
//  BaseCollectionViewCell.swift
//  ClothesShare
//
//  Created by admin on 8/15/19.
//  Copyright © 2019 ThanhPham. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    var callBackWithAction: ((_ action: Int?, _ value: Any?) -> ())?
    var callBackWithAction2: ((_ action: Int?, _ value: Any? , _ value: Any?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
