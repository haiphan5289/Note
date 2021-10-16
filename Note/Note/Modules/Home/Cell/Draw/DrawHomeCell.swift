//
//  DrawHomeCell.swift
//  Note
//
//  Created by haiphan on 16/10/2021.
//

import UIKit
import PencilKit

class DrawHomeCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateValueNote(noteModel: NoteDrawModel) {
        guard let d = noteModel.imageData, let image: UIImage = UIImage(data: d) else {
            return
        }
        self.img.image = image
        self.img.isHidden = false
    }

}
