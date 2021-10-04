//
//  ConfigText.swift
//  Note
//
//  Created by haiphan on 03/10/2021.
//

import UIKit
import RxSwift

protocol ConfigTextDelegate {
    func dismiss()
    func save()
    func showConfigText()
    func pickColor()
}

class ConfigText: UIView {
    
    enum Action: Int, CaseIterable {
        case close, save, pickColor, setText
    }
    
    @IBOutlet var bts: [UIButton]!
    
    var delegate: ConfigTextDelegate?
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
extension ConfigText {
    
    private func setupUI() {
        
    }
    
    private func setupRX() {
        Action.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch type {
                case .close:
                    wSelf.delegate?.dismiss()
                case .save:
                    wSelf.delegate?.save()
                case .pickColor:
                    wSelf.delegate?.pickColor()
                case .setText:
                    wSelf.delegate?.showConfigText()
                }
            }.disposed(by: disposeBag)
        }
        
    }
}
