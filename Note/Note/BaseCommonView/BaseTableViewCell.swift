//
//  BaseTableViewCell.swift
//  Keng
//
//  Created by admin on 4/29/19.
//  Copyright © 2019 Dong Nguyen. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    var callBackWithAction: ((_ action: Int?, _ value: Any?) -> ())?
    var callBackWithAction2: ((_ action: Int?, _ value: Any? , _ value: Any?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

class BaseUnSelectCell: BaseTableViewCell {
    override func awakeFromNib() {
        self.selectionStyle = .none
    }
}
