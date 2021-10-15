//
//  CheckListCell.swift
//  Note
//
//  Created by haiphan on 15/10/2021.
//

import UIKit

class CheckListCell: UITableViewCell {

    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI() {
        self.layer.cornerRadius = ConstantApp.shared.radiusHomeNoteCell
        self.setupImageBg()
    }
    
    private func setupImageBg() {
        self.imgBg.contentMode = .scaleToFill
        self.imgBg.clipsToBounds = true
        self.imgBg.isHidden = true
        self.addSubview( self.imgBg)
        self.sendSubviewToBack(self.imgBg)
        self.imgBg.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    

    
}
