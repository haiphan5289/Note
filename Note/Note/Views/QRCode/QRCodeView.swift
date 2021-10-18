//
//  QRCodeView.swift
//  Note
//
//  Created by haiphan on 18/10/2021.
//

import UIKit
import RxSwift

class QRCodeView: UIView {
    
    @IBOutlet var animationView: [UIView]!
    
    private var autoAnimation: Disposable?
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
extension QRCodeView {
    
    private func setupUI() {
        self.actionAutoAnimation()
    }
    
    private func setupRX() {
        
    }
    
    func actionAutoAnimation() {
        self.autoAnimation?.dispose()
        self.autoAnimation = Observable<Int>.interval(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] value in
                guard let wSelf = self else { return }
                wSelf.animationButton()
            })
    }
    
    func stopAnimation() {
        self.autoAnimation?.dispose()
    }
    
    private func animationButton() {
        UIView.animate(withDuration: 0.3,
            animations: {
                self.animationView.forEach { v in
                    v.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                }
                
            },
            completion: { complete in
                if complete {
                    UIView.animate(withDuration: 0.6) {
                        self.animationView.forEach { v in
                            v.transform = CGAffineTransform.identity
                        }
                        
                    }

                }
            })
    }
    
}
