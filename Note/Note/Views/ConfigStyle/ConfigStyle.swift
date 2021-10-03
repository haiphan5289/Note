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
                    wSelf.updateStatusKeyboard()
                case .text:
                    wSelf.updateStatusKeyboard()
                }
            }.disposed(by: disposeBag)
            
        }
    }
    
    func updateStatusKeyboard() {
        self.bts[ActionConfig.keyboard.rawValue].setImage(Asset.icKeyboard.image, for: .normal)
        self.bts[ActionConfig.keyboard.rawValue].isSelected = false
        self.delegate?.updateStatusKeyboard(status: .hide)
    }
}
