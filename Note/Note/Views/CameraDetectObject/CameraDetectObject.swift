//
//  CameraDetectObject.swift
//  Note
//
//  Created by haiphan on 20/10/2021.
//

import UIKit
import RxSwift
import Photos
import Vision
import Foundation
import AVFoundation

class CameraDetectObject: UIView {
    
    @IBOutlet weak var previewView: UIImageView!
    var imageCropVC: UIImage?
    var rectCropView: CGRect?
    
    private var noRectangleCount = 0
    
    /// The minimum number of time required by `noRectangleCount` to validate that no rectangles have been found.
    private let noRectangleThreshold = 3
    private let rectangleFunnel = RectangleFeaturesFunnel()
    private var displayedRectangleResult: RectangleDetectorResult?
    let quadView = QuadrilateralView()
    
    
    var captureSessionManager: CaptureSessionManager?
    let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    var focusRectangle: FocusRectangleView!
    
    private var maskLayer = CAShapeLayer()
    
    private var isTapped = false
    
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
extension CameraDetectObject {
    
    private func setupUI() {
        
        self.backgroundColor = .darkGray
        self.layer.addSublayer(videoPreviewLayer)
       
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        self.addSubview(quadView)
        
        var quadViewConstraints = [NSLayoutConstraint]()
        quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: self.topAnchor),
            self.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            self.trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
            quadView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints)
        
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer, delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }
    
    @objc private func subjectAreaDidChange() {
        /// Reset the focus and exposure back to automatic
        do {
            try CaptureSession.current.resetFocusToAuto()
        } catch {
            return
        }
        
        /// Remove the focus rectangle if one exists
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: true)
    }
    
    private func setupRX() {
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard  let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)
        
        focusRectangle = FocusRectangleView(touchPoint: touchPoint)
        self.addSubview(focusRectangle)
        
        do {
            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
    }
    
    
    //MARK: rectangle Detection
    private func detectRectangle(in image: CVPixelBuffer) {
        //removeMask()
        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                
                guard let results = request.results as? [VNRectangleObservation] else { return }
                self.removeMask()
                
                guard let rect = results.first else{return}
                self.drawBoundingBox(rect: rect)
                
                //Handle the button action
                self.imageCropVC = self.imageExtraction(rect, from: image)
            }
        })
        
        //Set the value for the detected rectangle
        request.minimumAspectRatio = VNAspectRatio(0.3)
        request.maximumAspectRatio = VNAspectRatio(0.9)
        request.minimumSize = Float(0.3)
        request.maximumObservations = 1
        
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    //MARK: drawing Bounding Box
    func drawBoundingBox(rect : VNRectangleObservation) {
//        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.bounds.height)
//        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.bounds.width, y: self.previewLayer.bounds.height)
//
//        let bounds = rect.boundingBox.applying(scale).applying(transform)
//
//        createLayer(in: bounds)
    }
    
    private func createLayer(in rect: CGRect) {
//        maskLayer = CAShapeLayer()
//        maskLayer.frame = rect
//        maskLayer.cornerRadius = 10
//        maskLayer.opacity = 1
//        maskLayer.borderColor = UIColor.systemBlue.cgColor
//        maskLayer.borderWidth = 6.0
//        previewLayer.insertSublayer(maskLayer, at: 1)
//        
//        self.rectCropView = rect
//        print("==== createLayer \(rect)")
        
    }
    
    func removeMask() {
        maskLayer.removeFromSuperlayer()
    }

    
    //MARK: Utilities
    func imageExtraction(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> UIImage {
        let ciImage = CIImage(cvImageBuffer: buffer)
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let output = UIImage(cgImage: cgImage!)
        
        //return image
        return output
    }
    
}

extension CameraDetectObject: RectangleDetectionDelegateProtocol {
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        
//        activityIndicator.stopAnimating()
//        shutterButton.isUserInteractionEnabled = true
//
//        guard let imageScannerController = navigationController as? ImageScannerController else { return }
//        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
    }
    
    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
//        activityIndicator.startAnimating()
//        captureSessionManager.stop()
//        shutterButton.isUserInteractionEnabled = false
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: Quadrilateral?) {
//        activityIndicator.stopAnimating()
//        
//        let editVC = EditScanViewController(image: picture, quad: quad)
//        navigationController?.pushViewController(editVC, animated: false)
//        
//        shutterButton.isUserInteractionEnabled = true
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, _ imageSize: CGSize) {
        guard let quad = quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            quadView.removeQuadrilateral()
            return
        }
        
        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)
        
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)

        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)

        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)
        
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        
        let transformedQuad = quad.applyTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
    }
    
}

