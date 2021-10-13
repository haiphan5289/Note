//
//  PathDraw.swift
//  Note
//
//  Created by haiphan on 02/10/2021.
//

import Foundation
import UIKit

final class PathDraw {
    
    struct Constant {
        static let cornerThreehour: CGFloat = 0
        static let cornerSixhour: CGFloat = CGFloat(90 * Double.pi/180.0)
        static let cornerNinehour: CGFloat = CGFloat(180 * Double.pi/180.0)
        static let cornerTwelvehour: CGFloat = CGFloat(270 * Double.pi/180.0)
    }
    
    static var shared = PathDraw()
    
    //Note Draw
    // góc 3h: startAngle: 0
    // Góc 6h: startAngle: CGFloat(90 * Double.pi/180.0)
    // Góc 9h: startAngle: CGFloat(180 * Double.pi/180.0)
    // Góc 12: startAngle: CGFloat(270 * Double.pi/180.0)
    
    private init() {}
    
    func setupShapeLayer(shapeLayer: CAShapeLayer, colorLine: UIColor) -> CAShapeLayer {
        shapeLayer.strokeColor = colorLine.cgColor
        shapeLayer.fillColor = Asset.appBg.color.cgColor
        shapeLayer.lineWidth = 0.5
//        shapeLayer.shadowOffset = CGSize(width:0, height:0)
//        shapeLayer.shadowRadius = 10
//        shapeLayer.shadowColor = UIColor.gray.cgColor
//        shapeLayer.shadowOpacity = 0.3
        return shapeLayer
    }
    
    func createPathDropDownAction(frame: CGRect, distanceToTop: CGFloat) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        let radius: CGFloat = 20 //change it if you want
        //let distancefromDropDownViewToBottom
        // This variable alaways have to be great than radius
//        let distanceToTop: CGFloat = 15
        let distantToDraw: CGFloat = 20
        
        
        path.addArc(withCenter: CGPoint(x: radius , y: radius + distanceToTop),
                    radius: radius,
                    startAngle: Constant.cornerNinehour,
                    endAngle: Constant.cornerTwelvehour, clockwise: true)
        
        path.addLine(to: CGPoint(x: frame.width - distantToDraw, y: distanceToTop))
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        //draw little circle
//        path.addLine(to: CGPoint(x: frame.width, y: frame.height))
        path.addArc(withCenter: CGPoint(x: frame.width - radius , y: frame.height - radius),
                    radius: radius,
                    startAngle: Constant.cornerThreehour,
                    endAngle: Constant.cornerSixhour, clockwise: true)
    
        path.addArc(withCenter: CGPoint(x: radius , y: frame.height - radius),
                    radius: radius,
                    startAngle: Constant.cornerSixhour,
                    endAngle: Constant.cornerNinehour, clockwise: true)
        path.lineCapStyle = .round
//        UIColor.red.setStroke()
//        path.stroke()
        path.close()
        return path.cgPath
    }
    
    func createPathDropDown(frame: CGRect, distancefromDropDownViewToBottom: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let centerWidth = frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0))
        let radius: CGFloat = 20 //change it if you want
        //let distancefromDropDownViewToBottom
        // This variable alaways have to be great than radius
        //draw little circle
        path.addArc(withCenter: CGPoint(x: radius , y: radius),
                    radius: radius,
                    startAngle: Constant.cornerNinehour,
                    endAngle: Constant.cornerTwelvehour, clockwise: true)
       
        //path.addLine(to: CGPoint(x: frame.width, y: 0))
        //draw little circle
        path.addArc(withCenter: CGPoint(x: frame.width - radius , y: radius),
                    radius: radius,
                    startAngle: Constant.cornerTwelvehour,
                    endAngle: Constant.cornerThreehour, clockwise: true)
        path.addLine(to: CGPoint(x: frame.width, y: frame.height - radius - distancefromDropDownViewToBottom))
        
        //draw little circle
        path.addArc(withCenter: CGPoint(x: frame.width - radius , y: frame.height - radius - distancefromDropDownViewToBottom),
                    radius: radius,
                    startAngle: Constant.cornerThreehour,
                    endAngle: Constant.cornerSixhour, clockwise: true)
        path.addLine(to: CGPoint(x: frame.width - radius, y: frame.height - distancefromDropDownViewToBottom))
        
        path.addLine(to: CGPoint(x: centerWidth + radius, y: frame.height - distancefromDropDownViewToBottom))
        path.addLine(to: CGPoint(x: centerWidth, y: frame.height))
        path.addLine(to: CGPoint(x: centerWidth - radius, y: frame.height - distancefromDropDownViewToBottom))
        path.addLine(to: CGPoint(x: radius, y: frame.height - distancefromDropDownViewToBottom ))
        //draw little circle
        path.addArc(withCenter: CGPoint(x: radius , y: frame.height - radius - distancefromDropDownViewToBottom),
                    radius: radius,
                    startAngle: Constant.cornerSixhour,
                    endAngle: Constant.cornerNinehour, clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: frame.height - radius - distancefromDropDownViewToBottom ))
        path.lineCapStyle = .round
//        UIColor.red.setStroke()
//        path.stroke()
        path.close()
        return path.cgPath
    }
}
