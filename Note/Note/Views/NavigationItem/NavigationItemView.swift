//
//  NavigationItemView.swift
//  Note
//
//  Created by haiphan on 02/10/2021.
//

import UIKit
import RxSwift

class NavigationItemView: UIView {
    
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
extension NavigationItemView {
    
    private func setupUI() {
        
    }
    
    private func setupRX() {
        
    }
}
 
