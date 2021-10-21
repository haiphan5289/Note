
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

class CHeckVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Add here outlets
    @IBOutlet weak var previewView: UIImageView!
    let cropView = CropView()
    
    // Add here your view model
    private var viewModel: CHeckVM = CHeckVM()
    
    private var isTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupInteractions()
    }
}
extension CHeckVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
    
    override func loadView() {
        self.view = self.cropView
    }
    
    private func setup() {
        self.cropView.image = Asset.sss.image
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
