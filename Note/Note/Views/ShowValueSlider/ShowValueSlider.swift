//
//  ShowValueSlider.swift
//  Audio
//
//  Created by haiphan on 10/09/2021.
//

import UIKit

class ShowValueSlider: UIView {
    
    private let imgPopup: UIImageView = UIImageView()
    private let lbValue: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")}
}
extension ShowValueSlider {
    
    private func setupUI() {
//        imgPopup.image = Asset.imgShowValueSlider.image
//        imgPopup.tintColor = Asset.color1.color
        self.addSubview(imgPopup)
        imgPopup.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        lbValue.textAlignment = .center
//        lbValue.textColor = Asset.color1.color
        lbValue.font = UIFont.mySystemFont(ofSize: 12)
        lbValue.adjustsFontSizeToFitWidth = true
        lbValue.minimumScaleFactor = 0.5
        self.addSubview(lbValue)
        lbValue.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
    }
    
    func updateValue(value: Float) {
        lbValue.text = "\(Int(value))"
        self.isHidden = false
    }
    
    func hideView() {
        self.isHidden = true
    }
    
}
