//
//  NoteStatusCell.swift
//  Note
//
//  Created by haiphan on 03/05/2022.
//

import UIKit

class NoteStatusCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension NoteStatusCell {
    
    func loadValue(note: HomeV2VC.NoteStatus) {
        self.lbTitle.text = note.title
        self.lbSubtitle.text = note.subTitle
        self.img.image = note.img
    }
}
