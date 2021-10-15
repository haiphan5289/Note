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
    func pickColor(color: UIColor)
}

class ConfigText: UIView {
    
    struct Constant {
        static let sizeColorWell: CGFloat = 30
    }
    
    enum Action: Int, CaseIterable {
        case close, save, setText
    }
    
    @IBOutlet var bts: [UIButton]!
    @IBOutlet weak var lbFontSize: UILabel!
    @IBOutlet weak var viewPickColor: UIView!
    
    private let colorWell: UIColorWell = UIColorWell(frame: .zero)
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
        lbFontSize.adjustsFontSizeToFitWidth = true
        lbFontSize.minimumScaleFactor = 0.2
        
        self.setupPickColor()
        
        self.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
                case .setText:
                    wSelf.delegate?.showConfigText()
                }
            }.disposed(by: disposeBag)
        }
        
        self.colorWell.rx.controlEvent(.valueChanged).bind { [weak self] _ in
            guard let wSelf = self, let color = wSelf.colorWell.selectedColor else { return }
            wSelf.delegate?.pickColor(color: color)
        }.disposed(by: disposeBag)
        
    }
    
    private func setupPickColor() {
        colorWell.supportsAlpha = true
        colorWell.selectedColor = Asset.colorApp.color
        colorWell.title = L10n.StyleView.pickColor
        colorWell.center = self.viewPickColor.center
        self.viewPickColor.addSubview(colorWell)
        colorWell.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(Constant.sizeColorWell)
        }
    }
    
    func addViewToParent(view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(BaseNavigationHeader.Constant.heightViewText + ConstantApp.shared.getHeightSafeArea(type: .bottom))
        }
    }
    
    func updateColorWellSelector(color: UIColor) {
        self.colorWell.selectedColor = color
    }
    
    func hideView() {
        self.isHidden = true
    }
    
    func showView() {
        self.isHidden = false
    }
    
    func showTextFont(font: UIFont) {
        self.lbFontSize.text = "\(font.familyName) - \(font.pointSize)"
    }

}
