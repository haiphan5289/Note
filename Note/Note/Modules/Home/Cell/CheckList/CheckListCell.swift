//
//  CheckListCell.swift
//  Note
//
//  Created by haiphan on 15/10/2021.
//

import UIKit

class CheckListCell: UICollectionViewCell {
    
    struct Constant {
        static let heightView: CGFloat = 30
    }

    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var removeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        
    }
    
    private func setupUI() {
        self.layer.cornerRadius = ConstantApp.shared.radiusHomeNoteCell
        self.setupImageBg()
        removeView.removeFromSuperview()
    }
    
    func updateValue(note: NoteModel) {
        guard let model = note.noteCheckList else {
            return
        }
        self.lbTitle.text = model.title
//        if let bg = note.bgColorModel, let f = bg.getFont() {
//            self.lbTitle.font = f
//        }
//
        if let bgColorModel = note.bgColorModel, let bgColorType = bgColorModel.getBgColorType()  {
            self.layoutIfNeeded()
            self.updateBgColorWhenDone(bgColorType: bgColorType)
        } else {
            NoteManage.shared.removeCAGradientLayer(view: self.contentView)
            self.imgBg.isHidden = true
            self.self.contentView.backgroundColor = .white
        }
        
        if let bg = note.bgColorModel, let textColor = bg.textColorString {
            self.lbTitle.textColor = textColor.covertToColor()
        } else {
            self.lbTitle.textColor = Asset.textColorApp.color
        }
        
        self.setupStackView(model: model)
        
    }
    
    private func setupStackView(model: NoteCheckListModel) {
        //Remove view to update again If Not, Data ưill show incorrectly
        self.stackView.removeSubviews()
        
        model.listToDo?.enumerated().forEach({ [weak self] item in
            guard let wSelf = self else { return }
            let v: UIView = UIView(frame: .zero)
            v.backgroundColor = .clear
            
            v.snp.makeConstraints { (make) in
                make.height.equalTo(Constant.heightView)
            }
            
            let imageView: UIImageView = UIImageView(frame: .zero)
            var img: UIImage
            if let list = model.listSelect, list.contains(where: { $0.row == item.offset }) {
                img = Asset.icCheckbox.image
            } else {
                img = Asset.icUncheck.image
            }
            imageView.tintColor = Asset.colorApp.color
            imageView.image = img
            v.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(16)
                make.width.height.equalTo(24)
            }
            
            let lbTodo: UILabel = UILabel(frame: .zero)
            lbTodo.numberOfLines = 1
            lbTodo.font = ConstantApp.shared.fontDefault
            lbTodo.textColor = wSelf.lbTitle.textColor
            lbTodo.textAlignment = .left
            lbTodo.text = item.element
            v.addSubview(lbTodo)
            lbTodo.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(imageView.snp.right).inset(-10)
                make.right.equalToSuperview().inset(16)
            }
            
            let lineView: UIView = UIView(frame: .zero)
            lineView.backgroundColor = Asset.viewLine.color
            v.addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            
            wSelf.stackView.addArrangedSubview(v)
            
        })
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
    
    func updateBgColorWhenDone(bgColorType: BackgroundColor.BgColorTypes) {
        switch bgColorType {
        case .gradient(let list ):
            NoteManage.shared.removeCAGradientLayer(view: self.contentView)
            self.contentView.backgroundColor = .clear
            self.imgBg.isHidden = true
            self.contentView.applyGradient(withColours: list.map { $0.covertToColor() }.compactMap{ $0 }, gradientOrientation: .vertical)
        case .colors(let color):
            NoteManage.shared.removeCAGradientLayer(view: self.contentView)
            if let color = color {
                self.imgBg.isHidden = true
                self.contentView.backgroundColor = color.covertToColor()
            }
        case .images(let img):
            NoteManage.shared.removeCAGradientLayer(view: self.contentView)
            if let img = img, let image = img.converToImage() {
                self.updateImgBg(img: image)
            }
        }
    }
    
    private func updateImgBg(img: UIImage) {
        self.contentView.backgroundColor = UIColor.clear
        self.imgBg.image = img
        self.imgBg.isHidden = false
    }
    

    
}
