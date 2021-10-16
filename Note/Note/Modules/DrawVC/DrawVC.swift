
//
//  
//  DrawVC.swift
//  Note
//
//  Created by haiphan on 16/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import PencilKit

class DrawVC: UIViewController {
    
    struct Constant {
        static let canvasWidth: CGFloat = 768
        static let canvasOverScrollHeight: CGFloat = 500
    }
    
    // Add here outlets
    @IBOutlet weak var canvasView: PKCanvasView!
    
    // Add here your view model
    private var viewModel: DrawVM = DrawVM()
    
    private var drawing = PKDrawing()
    private let toolPicker = PKToolPicker.init()
    
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
}
extension DrawVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        canvasView.delegate = self
        canvasView.alwaysBounceVertical = false
        canvasView.drawingPolicy = .default
        canvasView.becomeFirstResponder()
          
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        canvasView.becomeFirstResponder()
        
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
    
    private func updateDrawWhenChangeLayou() {
        let canvasScale = self.canvasView.bounds.width / Constant.canvasWidth
        self.canvasView.minimumZoomScale = canvasScale
        self.canvasView.maximumZoomScale = canvasScale
        self.canvasView.zoomScale = canvasScale

        self.canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }

}
extension DrawVC: PKCanvasViewDelegate {
}

extension DrawVC: PKToolPickerObserver {
    
    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerSelectedToolDidChange")
    }
    
    func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerIsRulerActiveDidChange")
    }
    
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerVisibilityDidChange")
    }
    
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerFramesObscuredDidChange")
    }
}
