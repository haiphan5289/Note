
//
//  
//  CHeckVC.swift
//  Note
//
//  Created by haiphan on 14/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import WebKit
import Photos
import Vision

class CHeckVC: UIViewController {
    
    // Add here outlets
    // Add here your view model
    private var viewModel: CHeckVM = CHeckVM()
    private var shapeLayer: CALayer?
    
    private var isTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension CHeckVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.addShape()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
    
    private func addShape() {
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = PathDraw.shared.createPathDropDown(frame: self.view.frame, distancefromDropDownViewToBottom: 50)
        shapeLayer = PathDraw.shared.setupShapeLayer(shapeLayer: shapeLayer, colorLine: .clear)

        if let oldShapeLayer = self.shapeLayer {
            self.view.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.view.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }

}
