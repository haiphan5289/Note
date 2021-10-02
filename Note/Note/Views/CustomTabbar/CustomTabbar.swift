//
//  CustomTabbar.swift
//  CameraMakeUp
//
//  Created by haiphan on 21/09/2021.
//

import Foundation
import UIKit

@IBDesignable
class CustomTabbar: UITabBar {
    
    enum TabItem: Int, CaseIterable {
        case home
        case menu

        var viewController: UIViewController {
            switch self {
            case .home:
                return HomeVC.createVC()
            case .menu:
                return HomeVC.createVC()
            }
        }
        
        var text: String {
            switch self {
            case .home:
                return L10n.Tabbar.home
            case .menu:
                return L10n.Tabbar.menu
            }
        }
        
        var img: UIImage {
            switch self {
            case .home:
                return Asset.icHome.image
            case .menu:
                return Asset.icMenu.image
            }
        }
    }
    
    private var shapeLayer: CALayer?

    override func draw(_ rect: CGRect) {
        self.addShape()
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = Asset.appBg.color.cgColor
        shapeLayer.lineWidth = 0.5
        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOpacity = 0.3

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }

    func createPath() -> CGPath {
        let bigRadius: CGFloat = ConstantCommon.shared.bigRadiusTabbar
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0))
        let radius: CGFloat = 10 //change it if you want
        let leftArcOriginX = centerWidth - bigRadius - radius
        let leftArcOriginY: CGFloat = 0
        path.addLine(to: CGPoint(x: leftArcOriginX, y: leftArcOriginY))
        // add left little arc, change angle if you want, if you dont want oval, may be you can use path.addCurve(to: , controlPoint1: , controlPoint2: )
        path.addArc(withCenter: CGPoint(x: leftArcOriginX, y: leftArcOriginY + radius), radius: radius, startAngle: CGFloat(270.0 * Double.pi/180.0), endAngle: 0, clockwise: true)
        // add big arc
        path.addArc(withCenter: CGPoint(x: centerWidth, y: radius), radius: bigRadius, startAngle: CGFloat(180.0 * Double.pi/180.0), endAngle: CGFloat(0 * Double.pi/180.0), clockwise: false)
        // add right litte arc
        path.addArc(withCenter: CGPoint(x: centerWidth + bigRadius + radius, y: radius), radius: radius, startAngle: CGFloat(180.0 * Double.pi/180.0), endAngle: CGFloat(270.0 * Double.pi/180.0), clockwise: true)
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.lineCapStyle = .round
//        UIColor.red.setStroke()
//        path.stroke()
        path.close()
        return path.cgPath
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

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 74
        return sizeThatFits
    }
}
