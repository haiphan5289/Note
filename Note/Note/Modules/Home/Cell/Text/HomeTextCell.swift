//
//  HomeTextCell.swift
//  Note
//
//  Created by haiphan on 12/10/2021.
//

import UIKit
import RxSwift

class HomeTextCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lbText: UILabel!
    @IBOutlet weak var imgSelect: UIImageView!
    
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
    }
    
    
    private func setupUI() {
        textView.clipsToBounds = true
        textView.centerVertically()
        textView.resignFirstResponder()
        self.setupImageBg()
    }
    
    private func setupRX() {
        self.textView.rx.didChange.asObservable().bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.textView.centerVertically()
        }.disposed(by: disposeBag)
    }
    
    func updateValue(note: NoteModel) {
        textView.centerVertically()
        self.lbText.text = note.text
        if let bg = note.bgColorModel, let f = bg.getFont() {
            self.lbText.font = f
        }
        
        if let bgColorModel = note.bgColorModel, let bgColorType = bgColorModel.getBgColorType()  {
            self.layoutIfNeeded()
            self.updateBgColorWhenDone(bgColorType: bgColorType)
        } else {
            self.removeCAGradientLayer()
            self.imgBg.isHidden = true
            self.textView.backgroundColor = .white
        }
        
        if let bg = note.bgColorModel, let textColor = bg.textColorString {
            self.lbText.textColor = textColor.covertToColor()
        } else {
            self.lbText.textColor = Asset.textColorApp.color
        }
        
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
            self.removeCAGradientLayer()
            self.textView.backgroundColor = .clear
            self.imgBg.isHidden = true
            self.textView.applyGradient(withColours: list.map { $0.covertToColor() }.compactMap{ $0 }, gradientOrientation: .vertical)
        case .colors(let color):
            self.removeCAGradientLayer()
            if let color = color {
                self.imgBg.isHidden = true
                self.textView.backgroundColor = color.covertToColor()
            }
        case .images(let img):
            self.removeCAGradientLayer()
            if let img = img, let image = img.converToImage() {
                self.updateImgBg(img: image)
            }
        }
    }
    
    private func updateImgBg(img: UIImage) {
        self.textView.backgroundColor = UIColor.clear
        self.imgBg.image = img
        self.imgBg.isHidden = false
    }
    
    private func removeCAGradientLayer() {
        guard let subplayers = self.textView.layer.sublayers else {
            return
        }
        
        for sublayer in subplayers where sublayer is CAGradientLayer {
            sublayer.removeFromSuperlayer()
        }
    }

}
