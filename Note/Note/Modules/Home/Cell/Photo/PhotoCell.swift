//
//  PhotoCell.swift
//  Note
//
//  Created by haiphan on 22/10/2021.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lbText: UILabel!
    @IBOutlet weak var imgSelect: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.layer.cornerRadius = ConstantApp.shared.radiusHomeNoteCell
    }
    
    private func setupUI() {
        self.setupImageBg()
    }
    
    func updateValue(note: NoteModel) {
        self.lbText.text = note.text
        if let bg = note.bgColorModel, let f = bg.getFont() {
            self.lbText.font = f
        }
        
        if let bg = note.bgColorModel, let textColor = bg.textColorString {
            self.lbText.textColor = textColor.covertToColor()
        } else {
            self.lbText.textColor = Asset.textColorApp.color
        }
        
        guard let model = note.notePhotoModel, let d = model.imgData, let image: UIImage = UIImage(data: d) else {
            return
        }
        self.imgBg.image = image
        self.imgBg.isHidden = false
        self.lbText.text = model.text
        
    }
    
    private func setupImageBg() {
        self.imgBg.contentMode = .scaleToFill
        self.imgBg.clipsToBounds = true
        self.imgBg.isHidden = true
//        self.addSubview( self.imgBg)
        self.sendSubviewToBack(self.imgBg)
//        self.imgBg.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
    }
    
}
