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

class CameraDetectObject: UIView {
    
    @IBOutlet weak var previewView: UIImageView!
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
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
        
    }
    
    private func setupRX() {
        
    }
    
    func startStepUp() {
        self.setCameraInput()
        self.showCameraFeed()
        self.setCameraOutput()
    }
    
    func updateFramePreview() {
        self.previewLayer.frame = self.previewView.bounds
    }
    
    func stopRunning() {
        self.videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        self.captureSession.stopRunning()
    }
    
    func startRunning() {
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.startRunning()
    }
    
    //MARK: Session initialisation and video output
    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .back).devices.first else {
                fatalError("No back camera device found.")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewView.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.previewView.frame
    }
    
    private func setCameraOutput() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        
        connection.videoOrientation = .portrait
    }
    
    //MARK: AVCaptureVideo Delegate
    func captureOutput(_ output: AVCaptureOutput,didOutput sampleBuffer: CMSampleBuffer,from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.detectRectangle(in: frame)
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
                if self.isTapped{
                    self.isTapped = false
                    //Handle image correction and estraxtion
//                    self.capturedImageView.contentMode = .scaleAspectFit
//                    self.capturedImageView.image = self.imageExtraction(rect, from: image)
                }
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
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.bounds.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.bounds.width, y: self.previewLayer.bounds.height)
        
        let bounds = rect.boundingBox.applying(scale).applying(transform)
        
        createLayer(in: bounds)
    }
    
    private func createLayer(in rect: CGRect) {
        maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.cornerRadius = 10
        maskLayer.opacity = 1
        maskLayer.borderColor = UIColor.systemBlue.cgColor
        maskLayer.borderWidth = 6.0
        previewLayer.insertSublayer(maskLayer, at: 1)
        
    }
    
    func removeMask() {
        maskLayer.removeFromSuperlayer()
    }

    
    //MARK: Utilities
    func imageExtraction(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> UIImage {
        var ciImage = CIImage(cvImageBuffer: buffer)
        
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        
        // pass filters to extract/rectify the image
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])
        
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let output = UIImage(cgImage: cgImage!)
        
        //return image
        return output
    }
    
}
extension CameraDetectObject: AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    //MARK: AVCaptureVideo Delegate
//    func captureOutput(_ output: AVCaptureOutput,didOutput sampleBuffer: CMSampleBuffer,from connection: AVCaptureConnection) {
//        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            debugPrint("unable to get image from sample buffer")
//            return
//        }
//        self.detectRectangle(in: frame)
//    }
//
//    //MARK: rectangle Detection
//    private func detectRectangle(in image: CVPixelBuffer) {
//        //removeMask()
//        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
//            DispatchQueue.main.async {
//
//                guard let results = request.results as? [VNRectangleObservation] else { return }
//                self.removeMask()
//
//                guard let rect = results.first else{return}
//                self.drawBoundingBox(rect: rect)
//
//                //Handle the button action
//                if self.isTapped{
//                    self.isTapped = false
//                    //Handle image correction and estraxtion
////                    self.capturedImageView.contentMode = .scaleAspectFit
////                    self.capturedImageView.image = self.imageExtraction(rect, from: image)
//                }
//            }
//        })
//
//        //Set the value for the detected rectangle
//        request.minimumAspectRatio = VNAspectRatio(0.3)
//        request.maximumAspectRatio = VNAspectRatio(0.9)
//        request.minimumSize = Float(0.3)
//        request.maximumObservations = 1
//
//
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
//        try? imageRequestHandler.perform([request])
//    }
//
//    //MARK: drawing Bounding Box
//    func drawBoundingBox(rect : VNRectangleObservation) {
//        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.bounds.height)
//        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.bounds.width, y: self.previewLayer.bounds.height)
//
//        let bounds = rect.boundingBox.applying(scale).applying(transform)
//
//        createLayer(in: bounds)
//    }
//
//    private func createLayer(in rect: CGRect) {
//        maskLayer = CAShapeLayer()
//        maskLayer.frame = rect
//        maskLayer.cornerRadius = 10
//        maskLayer.opacity = 1
//        maskLayer.borderColor = UIColor.systemBlue.cgColor
//        maskLayer.borderWidth = 6.0
//        previewLayer.insertSublayer(maskLayer, at: 1)
//
//    }
//
//    func removeMask() {
//        maskLayer.removeFromSuperlayer()
//    }
//
////    //MARK: Handle photo Button
////    @IBAction func didTakePhoto(_ sender: UIButton) {
////        self.isTapped = true
////    }
//
//    //MARK: Utilities
//    func imageExtraction(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> UIImage {
//        var ciImage = CIImage(cvImageBuffer: buffer)
//
//        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
//        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
//        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
//        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
//
//        // pass filters to extract/rectify the image
//        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
//            "inputTopLeft": CIVector(cgPoint: topLeft),
//            "inputTopRight": CIVector(cgPoint: topRight),
//            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//            "inputBottomRight": CIVector(cgPoint: bottomRight),
//        ])
//
//        let context = CIContext()
//        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
//        let output = UIImage(cgImage: cgImage!)
//
//        //return image
//        return output
//    }
    
    
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width,
                       y: self.y * size.height)
    }
}
