//
//  QRCodeTextView.swift
//  Note
//
//  Created by haiphan on 18/10/2021.
//

import UIKit
import RxSwift

protocol QRCodeTextViewDelegate {
    func tapAction(action: QRCodeTextView.Action)
}

class QRCodeTextView: UIView {
    
    enum Action: Int, CaseIterable {
        case cancel, done
    }
    
    var delegate: QRCodeTextViewDelegate?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var bts: [UIButton]!
    
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
extension QRCodeTextView {
    
    private func setupUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        textView.clipsToBounds = true
        textView.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        textView.centerVertically()
        textView.resignFirstResponder()
    }
    
    private func setupRX() {
        self.textView.rx.didChange.asObservable().bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.textView.centerVertically()
        }.disposed(by: disposeBag)
        
        Action.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.delegate?.tapAction(action: type)
            }.disposed(by: disposeBag)
            
        }
        
    }
    
    func getTextQRCode() -> String? {
        return self.textView.text
    }
    
    func updateValue(text: String) {
        self.textView.text = text
        textView.centerVertically()
    }
    
    func hideView() {
        self.isHidden = true
    }
    
    func showView() {
        self.isHidden = false
    }
    
}
