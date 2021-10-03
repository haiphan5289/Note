//
//  ConfigText.swift
//  Note
//
//  Created by haiphan on 03/10/2021.
//

import UIKit
import RxSwift

class ConfigText: UIView {
    
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
        
    }
}
