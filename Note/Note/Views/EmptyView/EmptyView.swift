//
//  EmptyView.swift
//  Tourist
//
//  Created by Dong Nguyen on 11/26/18.
//  Copyright © 2018 TVT25. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class EmptyView: UIView, Weakifiable {
    
    @IBOutlet weak var btMix: UIButton!
    @IBOutlet weak var lbText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func removeFromSuperview() {
        superview?.removeFromSuperview()
    }
    
}

extension EmptyView {
    private func setupUI() {
        
    }
    
    func hideButtonMix() {
        self.btMix.isHidden = true
    }
}
