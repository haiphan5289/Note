//
//  ViewExtension.swift
//  Dayshee
//
//  Created by haiphan on 11/1/20.
//  Copyright © 2020 ThanhPham. All rights reserved.
//

import UIKit

extension UIView {
    static var nib: UINib? {
        let bundle = Bundle(for: self)
        let name = "\(self)"
        guard bundle.path(forResource: name, ofType: "nib") != nil else {
            return nil
        }
        return UINib(nibName: name, bundle: nil)
    }
    
    
    static var identifier: String {
        return "\(self)"
    }
}

protocol LoadXibProtocol {}
extension LoadXibProtocol where Self: UIView {
    static func loadXib() -> Self {
        let bundle = Bundle(for: self)
        let name = "\(self)"
        guard let view = UINib(nibName: name, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("error xib \(name)")
        }
        return view
    }
}
extension UIView: LoadXibProtocol {}
extension UIView {
    func applyShadowAndRadius(sizeX: CGFloat, sizeY: CGFloat,shadowRadius: CGFloat, shadowColor: UIColor) {
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: sizeX, height: sizeY) //x,
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = shadowRadius //blur
        
        // add the border to subview
        //        let borderView = UIView()
        //        borderView.frame = self.bounds
        //        borderView.layer.cornerRadius = 10
        //
        //        borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.16)
        //        borderView.layer.borderWidth = 0.1
        //        borderView.layer.masksToBounds = true
        //        self.addSubview(borderView)
    }
    
    
    
//    @IBInspectable var borderColor: UIColor? {
//        get {
//            guard let color = layer.borderColor else { return nil }
//            return UIColor(cgColor: color)
//        }
//        set {
//            guard let color = newValue else {
//                layer.borderColor = nil
//                return
//            }
//            // Fix React-Native conflict issue
//            guard String(describing: type(of: color)) != "__NSCFType" else { return }
//            layer.borderColor = color.cgColor
//        }
//    }

    /// SwifterSwift: Border width of view; also inspectable from Storyboard.
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    /// SwifterSwift: Corner radius of view; also inspectable from Storyboard.
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
}
extension UIView {
//    func shake() {
//        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
//        animation.duration = 0.6
//        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
//        layer.add(animation, forKey: "shake")
//    }
    func shake(){
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y - 5))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y + 5))
            self.layer.add(animation, forKey: "position")
        }
}
extension UIView {
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   color: UIColor,
                   offSet: CGSize,
                   opacity: Float,
                   shadowRadius: CGFloat) {

        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offSet
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius

        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height

        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
}
