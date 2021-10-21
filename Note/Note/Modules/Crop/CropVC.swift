
//
//  
//  CropVC.swift
//  Note
//
//  Created by haiphan on 21/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class CropVC: UIViewController {
    
    // Add here outlets
    
    var imageDocument: UIImage?
    var rectCropView: CGRect?
    
    // Add here your view model
    private var viewModel: CropVM = CropVM()
    let cropView = CropView()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let rect = self.rectCropView {
            self.cropView.updateValueCropView(rect: rect)
        }
    }
    
}
extension CropVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.setup()
        self.setupInteractions()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
    override func loadView() {
        self.view = self.cropView
    }
    
    private func setup() {
        if let img = self.imageDocument {
            self.cropView.image = img
        }
    }
    
    private func setupInteractions() {
        self.cropView.didEndCropping = { [weak self] cropRect in
            guard let self = self else { return }
            
            // Generate the cropped image from cropRect (CGRect)
            if let image = self.cropView.image?.cgImage?.cropping(to: cropRect) {
                let croppedImage = UIImage(cgImage: image)
                print(croppedImage.size)
            }
        }
    }
}
