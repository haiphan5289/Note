
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
    private let cameraDetectObjectView: CameraDetectObject = CameraDetectObject.loadXib()
    
    // Add here your view model
    private var viewModel: CHeckVM = CHeckVM()
    
    private let disposeBag = DisposeBag()
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private var maskLayer = CAShapeLayer()
    
    private var isTapped = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //session Start
//        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
//        self.captureSession.startRunning()
        
        self.cameraDetectObjectView.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //session Stopped
//        self.videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
//        self.captureSession.stopRunning()
        
        self.cameraDetectObjectView.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.setCameraInput()
//        self.showCameraFeed()
//        self.setCameraOutput()
        self.view.addSubview(self.cameraDetectObjectView)
        self.cameraDetectObjectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.cameraDetectObjectView.startStepUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.previewLayer.frame = self.previewView.bounds
        
        self.cameraDetectObjectView.updateFramePreview()
    }
    
//    //MARK: Session initialisation and video output
//    private func setCameraInput() {
//        guard let device = AVCaptureDevice.DiscoverySession(
//            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
//            mediaType: .video,
//            position: .back).devices.first else {
//                fatalError("No back camera device found.")
//        }
//        let cameraInput = try! AVCaptureDeviceInput(device: device)
//        self.captureSession.addInput(cameraInput)
//    }
//
//    private func showCameraFeed() {
//        self.previewLayer.videoGravity = .resizeAspectFill
//        self.previewView.layer.addSublayer(self.previewLayer)
//        self.previewLayer.frame = self.previewView.frame
//    }
//
//    private func setCameraOutput() {
//        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
//
//        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
//        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
//        self.captureSession.addOutput(self.videoDataOutput)
//
//        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
//            connection.isVideoOrientationSupported else { return }
//
//        connection.videoOrientation = .portrait
//    }
//
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
extension CHeckVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
