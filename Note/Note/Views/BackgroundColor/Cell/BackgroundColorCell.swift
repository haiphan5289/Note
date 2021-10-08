//
//  BackgroundColorCell.swift
//  Note
//
//  Created by haiphan on 08/10/2021.
//

import UIKit

class BackgroundColorCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        self.cornerRadius = ConstantCommon.shared.radiusCellBgColor
    }

}
