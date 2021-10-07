//
//  ConfigStyle.swift
//  Note
//
//  Created by haiphan on 03/10/2021.
//

import UIKit
import RxSwift

protocol ConfigStyleDelegate {
    func updateStatusKeyboard(status: ConfigStyle.StatusKeyboard)
    func showConfigStyleText()
}

class ConfigStyle: UIView {
    
    enum ActionConfig: Int, CaseIterable {
        case text, color, keyboard
    }
    
    enum StatusKeyboard {
        case open, hide
    }
    
    @IBOutlet var bts: [UIButton]!
    
    var delegate: ConfigStyleDelegate?
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupRX()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func removeFromSuperview() {
        superview?.removeFromSuperview()
    }
}
extension ConfigStyle {
    
    private func setupUI() {
    }
    
    private func setupRX() {
        ActionConfig.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch type {
                case .keyboard:
                    
                    if bt.isSelected {
                        bt.setImage(Asset.icKeyboard.image, for: .normal)
                        bt.isSelected = false
                        wSelf.delegate?.updateStatusKeyboard(status: .hide)
                    } else {
                        bt.setImage(Asset.icHideKeyboard.image, for: .normal)
                        bt.isSelected = true
                        wSelf.delegate?.updateStatusKeyboard(status: .open)
                    }
                case .color:
                    wSelf.updateStatusKeyboard(status: .hide, updateStatus: true)
                case .text:
                    wSelf.updateStatusKeyboard(status: .hide, updateStatus: true)
                    wSelf.delegate?.showConfigStyleText()
                }
            }.disposed(by: disposeBag)
            
        }
    }
    
   
    
    func updateStatusKeyboard(status: StatusKeyboard, updateStatus: Bool = false) {
        switch status {
        case .hide:
            self.bts[ActionConfig.keyboard.rawValue].setImage(Asset.icKeyboard.image, for: .normal)
            self.bts[ActionConfig.keyboard.rawValue].isSelected = false
            
            if updateStatus {
                self.delegate?.updateStatusKeyboard(status: .hide)
            }
            
        case .open:
            self.bts[ActionConfig.keyboard.rawValue].setImage(Asset.icHideKeyboard.image, for: .normal)
            self.bts[ActionConfig.keyboard.rawValue].isSelected = true
            
            if updateStatus {
                self.delegate?.updateStatusKeyboard(status: .open)
            }
        }
        
    }
    
    func setupConfigStyleWithoutKeyboard() {
        self.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(BaseNavigationHeader.Constant.heightViewStyle + ConstantCommon.shared.getHeightSafeArea(type: .bottom))
        }
    }
    
    func setupConfigStyleWHaveKeyboard(height: CGFloat) {
        self.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(BaseNavigationHeader.Constant.heightViewStyle)
            make.bottom.equalToSuperview().inset(height)
        }
    }
}
