//
//  DropdownActionView.swift
//  Note
//
//  Created by haiphan on 12/10/2021.
//

import UIKit
import RxSwift

class DropdownActionView: UIView {
    
    struct Constant {
        static let width: CGFloat = 150
        static let height: CGFloat = 300
    }
    
    private var shapeLayer: CALayer?
    
    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupRX()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        self.addShape()
    }
    
}
extension DropdownActionView {
    
    private func setupUI() {
        
    }
    
    private func setupRX() {
        
    }
    
    private func addShape() {
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = PathDraw.shared.createPathDropDownAction(frame: self.frame)
        shapeLayer = PathDraw.shared.setupShapeLayer(shapeLayer: shapeLayer, colorLine: .clear)

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else { continue }
            return result
        }
        return nil
    }
    
}
