//
//  ToDoCell.swift
//  Note
//
//  Created by haiphan on 15/10/2021.
//

import UIKit

class ToDoCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        img.image = (selected) ? Asset.icCheckbox.image : Asset.icUncheck.image
    }
    
    func updateFont(font: UIFont)  {
        self.lbName.font = font
        
    }
    
    func updateColor(color: UIColor) {
        self.lbName.textColor = color
    }
    
}
