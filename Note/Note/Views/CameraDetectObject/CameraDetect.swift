//
//  CaptureManager.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import CoreMotion
import AVFoundation
import UIKit
import CoreMotion
import Photos
import Vision

/// A set of functions that inform the delegate object of the state of the detection.
protocol RectangleDetectionDelegateProtocol: NSObjectProtocol {
    
    /// Called when the capture of a picture has started.
    ///
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` instance that started capturing a picture.
    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager)
    
    /// Called when a quadrilateral has been detected.
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` instance that has detected a quadrilateral.
    ///   - quad: The detected quadrilateral in the coordinates of the image.
    ///   - imageSize: The size of the image the quadrilateral has been detected on.
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, _ imageSize: CGSize)
    
    /// Called when a picture with or without a quadrilateral has been captured.
    ///
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` instance that has captured a picture.
    ///   - picture: The picture that has been captured.
    ///   - quad: The quadrilateral that was detected in the picture's coordinates if any.
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: Quadrilateral?)
    
    /// Called when an error occured with the capture session manager.
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` that encountered an error.
    ///   - error: The encountered error.
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error)
}

/// The CaptureSessionManager is responsible for setting up and managing the AVCaptureSession and the functions related to capturing.
final class CaptureSessionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let videoPreviewLayer: AVCaptureVideoPreviewLayer
    private let captureSession = AVCaptureSession()
    private let rectangleFunnel = RectangleFeaturesFunnel()
    weak var delegate: RectangleDetectionDelegateProtocol?
    private var displayedRectangleResult: RectangleDetectorResult?
    private var photoOutput = AVCapturePhotoOutput()
    
    /// Whether the CaptureSessionManager should be detecting quadrilaterals.
    private var isDetecting = true
    
    /// The number of times no rectangles have been found in a row.
    private var noRectangleCount = 0
    
    /// The minimum number of time required by `noRectangleCount` to validate that no rectangles have been found.
    private let noRectangleThreshold = 3
    
    // MARK: Life Cycle
    
    init?(videoPreviewLayer: AVCaptureVideoPreviewLayer, delegate: RectangleDetectionDelegateProtocol? = nil) {
        self.videoPreviewLayer = videoPreviewLayer
        
        if delegate != nil {
            self.delegate = delegate
        }
        
        super.init()
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return nil
        }
        
        captureSession.beginConfiguration()
        
        let photoPreset = AVCaptureSession.Preset.photo
        
        if captureSession.canSetSessionPreset(photoPreset) {
            captureSession.sessionPreset = photoPreset
        }
        
        photoOutput.isHighResolutionCaptureEnabled = true
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        defer {
            device.unlockForConfiguration()
            captureSession.commitConfiguration()
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(deviceInput),
            captureSession.canAddOutput(photoOutput),
            captureSession.canAddOutput(videoOutput) else {
                return
        }
        
        do {
            try device.lockForConfiguration()
        } catch {
            return
        }
        
        device.isSubjectAreaChangeMonitoringEnabled = true
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_ouput_queue"))
    }
    
    // MARK: Capture Session Life Cycle
    
    /// Starts the camera and detecting quadrilaterals.
    internal func start() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
            isDetecting = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (_) in
                DispatchQueue.main.async { [weak self] in
                    self?.start()
                }
            })
        default: break
        }
    }
    
    internal func stop() {
        captureSession.stopRunning()
    }
    
    internal func capturePhoto() {
        guard let connection = photoOutput.connection(with: .video), connection.isEnabled, connection.isActive else {
            return
        }
        CaptureSession.current.setImageOrientation()
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isDetecting == true,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let imageSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

        if #available(iOS 11.0, *) {
            VisionRectangleDetector.rectangle(forPixelBuffer: pixelBuffer) { (rectangle) in
                self.processRectangle(rectangle: rectangle, imageSize: imageSize)
            }
        } else {
            let finalImage = CIImage(cvPixelBuffer: pixelBuffer)
            CIRectangleDetector.rectangle(forImage: finalImage) { (rectangle) in
                self.processRectangle(rectangle: rectangle, imageSize: imageSize)
            }
        }
    }
    
    private func processRectangle(rectangle: Quadrilateral?, imageSize: CGSize) {
        if let rectangle = rectangle {
            
            self.noRectangleCount = 0
            self.rectangleFunnel.add(rectangle, currentlyDisplayedRectangle: self.displayedRectangleResult?.rectangle) { [weak self] (result, rectangle) in
                
                guard let strongSelf = self else {
                    return
                }
                
                let shouldAutoScan = (result == .showAndAutoScan)
                strongSelf.displayRectangleResult(rectangleResult: RectangleDetectorResult(rectangle: rectangle, imageSize: imageSize))
                if shouldAutoScan, CaptureSession.current.isAutoScanEnabled, !CaptureSession.current.isEditing {
                    capturePhoto()
                }
            }
            
        } else {
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.noRectangleCount += 1
                
                if strongSelf.noRectangleCount > strongSelf.noRectangleThreshold {
                    // Reset the currentAutoScanPassCount, so the threshold is restarted the next time a rectangle is found
                    strongSelf.rectangleFunnel.currentAutoScanPassCount = 0
                    
                    // Remove the currently displayed rectangle as no rectangles are being found anymore
                    strongSelf.displayedRectangleResult = nil
                    strongSelf.delegate?.captureSessionManager(strongSelf, didDetectQuad: nil, imageSize)
                }
            }
            return
            
        }
    }
    
    @discardableResult private func displayRectangleResult(rectangleResult: RectangleDetectorResult) -> Quadrilateral {
        displayedRectangleResult = rectangleResult
        
        let quad = rectangleResult.rectangle.toCartesian(withHeight: rectangleResult.imageSize.height)
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.delegate?.captureSessionManager(strongSelf, didDetectQuad: quad, rectangleResult.imageSize)
        }
        
        return quad
    }
    
}

extension CaptureSessionManager: AVCapturePhotoCaptureDelegate {

    // swiftlint:disable function_parameter_count
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
//        if let error = error {
//            delegate?.captureSessionManager(self, didFailWithError: error)
//            return
//        }
//
//        isDetecting = false
//        rectangleFunnel.currentAutoScanPassCount = 0
//        delegate?.didStartCapturingPicture(for: self)
//
//        if let sampleBuffer = photoSampleBuffer,
//            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
//            completeImageCapture(with: imageData)
//        } else {
//
//            return
//        }
        
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //Don't capture picture
//        if let error = error {
//            delegate?.captureSessionManager(self, didFailWithError: error)
//            return
//        }
//
//        isDetecting = false
//        rectangleFunnel.currentAutoScanPassCount = 0
//        delegate?.didStartCapturingPicture(for: self)
//
//        if let imageData = photo.fileDataRepresentation() {
//            completeImageCapture(with: imageData)
//        } else {
//            return
//        }
    }
    
    /// Completes the image capture by processing the image, and passing it to the delegate object.
    /// This function is necessary because the capture functions for iOS 10 and 11 are decoupled.
    private func completeImageCapture(with imageData: Data) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            CaptureSession.current.isEditing = true
            guard let image = UIImage(data: imageData) else {
                return
            }
            
            var angle: CGFloat = 0.0
            
            switch image.imageOrientation {
            case .right:
                angle = CGFloat.pi / 2
            case .up:
                angle = CGFloat.pi
            default:
                break
            }
            
            var quad: Quadrilateral?
            if let displayedRectangleResult = self?.displayedRectangleResult {
                quad = self?.displayRectangleResult(rectangleResult: displayedRectangleResult)
                quad = quad?.scale(displayedRectangleResult.imageSize, image.size, withRotationAngle: angle)
            }
            
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.delegate?.captureSessionManager(strongSelf, didCapturePicture: image, withQuad: quad)
            }
        }
    }
}

/// Data structure representing the result of the detection of a quadrilateral.
struct RectangleDetectorResult {
    
    /// The detected quadrilateral.
    let rectangle: Quadrilateral
    
    /// The size of the image the quadrilateral was detected on.
    let imageSize: CGSize
    
}

/// Extension to CaptureSession with support for automatically detecting the current orientation via CoreMotion
/// Which works even if the user has enabled portrait lock.
extension CaptureSession {
    /// Detect the current orientation of the device with CoreMotion and use it to set the `editImageOrientation`.
    func setImageOrientation() {
        let motion = CMMotionManager()
        
        /// This value should be 0.2, but since we only need one cycle (and stop updates immediately),
        /// we set it low to get the orientation immediately
        motion.accelerometerUpdateInterval = 0.01
        
        guard motion.isAccelerometerAvailable else { return }
        
        motion.startAccelerometerUpdates(to: OperationQueue()) { data, error in
            guard let data = data, error == nil else { return }
            
            /// The minimum amount of sensitivity for the landscape orientations
            /// This is to prevent the landscape orientation being incorrectly used
            /// Higher = easier for landscape to be detected, lower = easier for portrait to be detected
            let motionThreshold = 0.35
            
            if data.acceleration.x >= motionThreshold {
                self.editImageOrientation = .left
            } else if data.acceleration.x <= -motionThreshold {
                self.editImageOrientation = .right
            } else {
                /// This means the device is either in the 'up' or 'down' orientation, BUT,
                /// it's very rare for someone to be using their phone upside down, so we use 'up' all the time
                /// Which prevents accidentally making the document be scanned upside down
                self.editImageOrientation = .up
            }
            
            motion.stopAccelerometerUpdates()
            
            // If the device is reporting a specific landscape orientation, we'll use it over the accelerometer's update.
            // We don't use this to check for "portrait" because only the accelerometer works when portrait lock is enabled.
            // For some reason, the left/right orientations are incorrect (flipped) :/
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                self.editImageOrientation = .right
            case .landscapeRight:
                self.editImageOrientation = .left
            default:
                break
            }
        }
    }
}
/// A class containing global variables and settings for this capture session
final class CaptureSession {
    
    static let current = CaptureSession()
    
    /// The AVCaptureDevice used for the flash and focus setting
    var device: CaptureDevice?
    
    /// Whether the user is past the scanning screen or not (needed to disable auto scan on other screens)
    var isEditing: Bool
    
    /// The status of auto scan. Auto scan tries to automatically scan a detected rectangle if it has a high enough accuracy.
    var isAutoScanEnabled: Bool
    
    /// The orientation of the captured image
    var editImageOrientation: CGImagePropertyOrientation
    
    private init(isAutoScanEnabled: Bool = true, editImageOrientation: CGImagePropertyOrientation = .up) {
        self.device = AVCaptureDevice.default(for: .video)
        
        self.isEditing = false
        self.isAutoScanEnabled = isAutoScanEnabled
        self.editImageOrientation = editImageOrientation
    }
    
}
/// Class used to detect rectangles from an image.
enum CIRectangleDetector {
    
    static let rectangleDetector = CIDetector(ofType: CIDetectorTypeRectangle,
                                              context: CIContext(options: nil),
                                              options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    
    /// Detects rectangles from the given image on iOS 10.
    ///
    /// - Parameters:
    ///   - image: The image to detect rectangles on.
    /// - Returns: The biggest detected rectangle on the image.
    static func rectangle(forImage image: CIImage, completion: @escaping ((Quadrilateral?) -> Void)) {
        let biggestRectangle = rectangle(forImage: image)
        completion(biggestRectangle)
    }
    
    static func rectangle(forImage image: CIImage) -> Quadrilateral? {
        guard let rectangleFeatures = rectangleDetector?.features(in: image) as? [CIRectangleFeature] else {
            return nil
        }
        
        let quads = rectangleFeatures.map { rectangle in
            return Quadrilateral(rectangleFeature: rectangle)
        }
        
        return quads.biggest()
    }
}
protocol CaptureDevice: class {
    var torchMode: AVCaptureDevice.TorchMode { get set }
    var isTorchAvailable: Bool { get }
    
    var focusMode: AVCaptureDevice.FocusMode { get set }
    var focusPointOfInterest: CGPoint { get set }
    var isFocusPointOfInterestSupported: Bool { get }
    
    var exposureMode: AVCaptureDevice.ExposureMode { get set }
    var exposurePointOfInterest: CGPoint { get set }
    var isExposurePointOfInterestSupported: Bool { get }

    var isSubjectAreaChangeMonitoringEnabled: Bool { get set }

    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool
    func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool
    func unlockForConfiguration()
    func lockForConfiguration() throws
}

extension AVCaptureDevice: CaptureDevice { }

final class MockCaptureDevice: CaptureDevice {
    var torchMode: AVCaptureDevice.TorchMode = .off
    var isTorchAvailable: Bool = true
    
    var focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
    var focusPointOfInterest: CGPoint = .zero
    var isFocusPointOfInterestSupported: Bool = true
    
    var exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
    var exposurePointOfInterest: CGPoint = .zero
    var isExposurePointOfInterestSupported: Bool = true
    var isSubjectAreaChangeMonitoringEnabled: Bool = false

    func unlockForConfiguration() {
        return
    }

    func lockForConfiguration() throws {
        return
    }

    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool {
        return true
    }
    
    func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool {
        return true
    }
}
import Foundation

/// Extension to CaptureSession that controls auto focus
extension CaptureSession {
    /// Sets the camera's exposure and focus point to the given point
    func setFocusPointToTapPoint(_ tapPoint: CGPoint) throws {
        guard let device = device else {
            let error = ImageScannerControllerError.inputDevice
            throw error
        }
        
        try device.lockForConfiguration()
        
        defer {
            device.unlockForConfiguration()
        }
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            device.focusPointOfInterest = tapPoint
            device.focusMode = .autoFocus
        }
        
        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposurePointOfInterest = tapPoint
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    /// Resets the camera's exposure and focus point to automatic
    func resetFocusToAuto() throws {
        guard let device = device else {
            let error = ImageScannerControllerError.inputDevice
            throw error
        }
        
        try device.lockForConfiguration()
        
        defer {
            device.unlockForConfiguration()
        }
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    /// Removes an existing focus rectangle if one exists, optionally animating the exit
    func removeFocusRectangleIfNeeded(_ focusRectangle: FocusRectangleView?, animated: Bool) {
        guard let focusRectangle = focusRectangle else { return }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 1.0, animations: {
                focusRectangle.alpha = 0.0
            }, completion: { (_) in
                focusRectangle.removeFromSuperview()
            })
        } else {
            focusRectangle.removeFromSuperview()
        }
    }
}
/// Errors related to the `ImageScannerController`
public enum ImageScannerControllerError: Error {
    /// The user didn't grant permission to use the camera.
    case authorization
    /// An error occured when setting up the user's device.
    case inputDevice
    /// An error occured when trying to capture a picture.
    case capture
    /// Error when creating the CIImage.
    case ciImageCreation
}

extension ImageScannerControllerError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .authorization:
            return "Failed to get the user's authorization for camera."
        case .inputDevice:
            return "Could not setup input device."
        case .capture:
            return "Could not capture picture."
        case .ciImageCreation:
            return "Internal Error - Could not create CIImage"
        }
    }

}
/// A yellow rectangle used to display the last 'tap to focus' point
final class FocusRectangleView: UIView {
    convenience init(touchPoint: CGPoint) {
        let originalSize: CGFloat = 200
        let finalSize: CGFloat = 80
        
        // Here, we create the frame to be the `originalSize`, with it's center being the `touchPoint`.
        self.init(frame: CGRect(x: touchPoint.x - (originalSize / 2), y: touchPoint.y - (originalSize / 2), width: originalSize, height: originalSize))
        
        backgroundColor = .clear
        layer.borderWidth = 2.0
        layer.cornerRadius = 6.0
        layer.borderColor = UIColor.yellow.cgColor
        
        // Here, we animate the rectangle from the `originalSize` to the `finalSize` by calculating the difference.
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.origin.x += (originalSize - finalSize) / 2
            self.frame.origin.y += (originalSize - finalSize) / 2
            
            self.frame.size.width -= (originalSize - finalSize)
            self.frame.size.height -= (originalSize - finalSize)
        })
    }
    
    public func setBorder(color: CGColor) {
        layer.borderColor = color
    }
    
}



extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width,
                       y: self.y * size.height)
    }
}

/// Class used to detect rectangles from an image.
@available(iOS 11.0, *)
enum VisionRectangleDetector {

    private static func completeImageRequest(for request: VNImageRequestHandler, width: CGFloat, height: CGFloat, completion: @escaping ((Quadrilateral?) -> Void)) {
        // Create the rectangle request, and, if found, return the biggest rectangle (else return nothing).
        let rectangleDetectionRequest: VNDetectRectanglesRequest = {
            let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: { (request, error) in
                guard error == nil, let results = request.results as? [VNRectangleObservation], !results.isEmpty else {
                    completion(nil)
                    return
                }

                let quads: [Quadrilateral] = results.map(Quadrilateral.init)

                guard let biggest = quads.biggest() else { // This can't fail because the earlier guard protected against an empty array, but we use guard because of SwiftLint
                    completion(nil)
                    return
                }

                let transform = CGAffineTransform.identity
                    .scaledBy(x: width, y: height)

                completion(biggest.applying(transform))
            })

            rectDetectRequest.minimumConfidence = 0.8
            rectDetectRequest.maximumObservations = 15
            rectDetectRequest.minimumAspectRatio = 0.3

            return rectDetectRequest
        }()

        // Send the requests to the request handler.
        do {
            try request.perform([rectangleDetectionRequest])
        } catch {
            completion(nil)
            return
        }

    }
    
    /// Detects rectangles from the given CVPixelBuffer/CVImageBuffer on iOS 11 and above.
    ///
    /// - Parameters:
    ///   - pixelBuffer: The pixelBuffer to detect rectangles on.
    ///   - completion: The biggest rectangle on the CVPixelBuffer
    static func rectangle(forPixelBuffer pixelBuffer: CVPixelBuffer, completion: @escaping ((Quadrilateral?) -> Void)) {
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        VisionRectangleDetector.completeImageRequest(
            for: imageRequestHandler,
            width: CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
            height: CGFloat(CVPixelBufferGetHeight(pixelBuffer)),
            completion: completion)
    }
    
    /// Detects rectangles from the given image on iOS 11 and above.
    ///
    /// - Parameters:
    ///   - image: The image to detect rectangles on.
    /// - Returns: The biggest rectangle detected on the image.
    static func rectangle(forImage image: CIImage, completion: @escaping ((Quadrilateral?) -> Void)) {
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        VisionRectangleDetector.completeImageRequest(
            for: imageRequestHandler, width: image.extent.width,
            height: image.extent.height, completion: completion)
    }
    
    static func rectangle(forImage image: CIImage, orientation: CGImagePropertyOrientation, completion: @escaping ((Quadrilateral?) -> Void)) {
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, orientation: orientation, options: [:])
        let orientedImage = image.oriented(orientation)
        VisionRectangleDetector.completeImageRequest(
            for: imageRequestHandler, width: orientedImage.extent.width,
            height: orientedImage.extent.height, completion: completion)
    }
}
//
//  Quadrilateral.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

/// A data structure representing a quadrilateral and its position. This class exists to bypass the fact that CIRectangleFeature is read-only.
public struct Quadrilateral: Transformable {
    
    /// A point that specifies the top left corner of the quadrilateral.
    public var topLeft: CGPoint
    
    /// A point that specifies the top right corner of the quadrilateral.
    public var topRight: CGPoint
    
    /// A point that specifies the bottom right corner of the quadrilateral.
    public var bottomRight: CGPoint
    
    /// A point that specifies the bottom left corner of the quadrilateral.
    public var bottomLeft: CGPoint

    public var description: String {
        return "topLeft: \(topLeft), topRight: \(topRight), bottomRight: \(bottomRight), bottomLeft: \(bottomLeft)"
    }

    /// The path of the Quadrilateral as a `UIBezierPath`
    var path: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()

        return path
    }

    /// The perimeter of the Quadrilateral
    var perimeter: Double {
        let perimeter = topLeft.distanceTo(point: topRight) + topRight.distanceTo(point: bottomRight) + bottomRight.distanceTo(point: bottomLeft) + bottomLeft.distanceTo(point: topLeft)
        return Double(perimeter)
    }
    
    init(rectangleFeature: CIRectangleFeature) {
        self.topLeft = rectangleFeature.topLeft
        self.topRight = rectangleFeature.topRight
        self.bottomLeft = rectangleFeature.bottomLeft
        self.bottomRight = rectangleFeature.bottomRight
    }

    @available(iOS 11.0, *)
    init(rectangleObservation: VNRectangleObservation) {
        self.topLeft = rectangleObservation.topLeft
        self.topRight = rectangleObservation.topRight
        self.bottomLeft = rectangleObservation.bottomLeft
        self.bottomRight = rectangleObservation.bottomRight
    }

    init(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }
    
    /// Applies a `CGAffineTransform` to the quadrilateral.
    ///
    /// - Parameters:
    ///   - t: the transform to apply.
    /// - Returns: The transformed quadrilateral.
    func applying(_ transform: CGAffineTransform) -> Quadrilateral {
        let quadrilateral = Quadrilateral(topLeft: topLeft.applying(transform), topRight: topRight.applying(transform), bottomRight: bottomRight.applying(transform), bottomLeft: bottomLeft.applying(transform))
        
        return quadrilateral
    }
    
    /// Checks whether the quadrilateral is withing a given distance of another quadrilateral.
    ///
    /// - Parameters:
    ///   - distance: The distance (threshold) to use for the condition to be met.
    ///   - rectangleFeature: The other rectangle to compare this instance with.
    /// - Returns: True if the given rectangle is within the given distance of this rectangle instance.
    func isWithin(_ distance: CGFloat, ofRectangleFeature rectangleFeature: Quadrilateral) -> Bool {
        
        let topLeftRect = topLeft.surroundingSquare(withSize: distance)
        if !topLeftRect.contains(rectangleFeature.topLeft) {
            return false
        }
        
        let topRightRect = topRight.surroundingSquare(withSize: distance)
        if !topRightRect.contains(rectangleFeature.topRight) {
            return false
        }
        
        let bottomRightRect = bottomRight.surroundingSquare(withSize: distance)
        if !bottomRightRect.contains(rectangleFeature.bottomRight) {
            return false
        }
        
        let bottomLeftRect = bottomLeft.surroundingSquare(withSize: distance)
        if !bottomLeftRect.contains(rectangleFeature.bottomLeft) {
            return false
        }
        
        return true
    }
    
    /// Reorganizes the current quadrilateal, making sure that the points are at their appropriate positions. For example, it ensures that the top left point is actually the top and left point point of the quadrilateral.
    mutating func reorganize() {
        let points = [topLeft, topRight, bottomRight, bottomLeft]
        let ySortedPoints = sortPointsByYValue(points)
        
        guard ySortedPoints.count == 4 else {
            return
        }
        
        let topMostPoints = Array(ySortedPoints[0..<2])
        let bottomMostPoints = Array(ySortedPoints[2..<4])
        let xSortedTopMostPoints = sortPointsByXValue(topMostPoints)
        let xSortedBottomMostPoints = sortPointsByXValue(bottomMostPoints)
        
        guard xSortedTopMostPoints.count > 1,
            xSortedBottomMostPoints.count > 1 else {
                return
        }
        
        topLeft = xSortedTopMostPoints[0]
        topRight = xSortedTopMostPoints[1]
        bottomRight = xSortedBottomMostPoints[1]
        bottomLeft = xSortedBottomMostPoints[0]
    }
    
    /// Scales the quadrilateral based on the ratio of two given sizes, and optionaly applies a rotation.
    ///
    /// - Parameters:
    ///   - fromSize: The size the quadrilateral is currently related to.
    ///   - toSize: The size to scale the quadrilateral to.
    ///   - rotationAngle: The optional rotation to apply.
    /// - Returns: The newly scaled and potentially rotated quadrilateral.
    func scale(_ fromSize: CGSize, _ toSize: CGSize, withRotationAngle rotationAngle: CGFloat = 0.0) -> Quadrilateral {
        var invertedfromSize = fromSize
        let rotated = rotationAngle != 0.0
        
        if rotated && rotationAngle != CGFloat.pi {
            invertedfromSize = CGSize(width: fromSize.height, height: fromSize.width)
        }
        
        var transformedQuad = self
        let invertedFromSizeWidth = invertedfromSize.width == 0 ? .leastNormalMagnitude : invertedfromSize.width
        let invertedFromSizeHeight = invertedfromSize.height == 0 ? .leastNormalMagnitude : invertedfromSize.height
        
        let scaleWidth = toSize.width / invertedFromSizeWidth
        let scaleHeight = toSize.height / invertedFromSizeHeight
        let scaledTransform = CGAffineTransform(scaleX: scaleWidth, y: scaleHeight)
        transformedQuad = transformedQuad.applying(scaledTransform)
        
        if rotated {
            let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
            
            let fromImageBounds = CGRect(origin: .zero, size: fromSize).applying(scaledTransform).applying(rotationTransform)
            
            let toImageBounds = CGRect(origin: .zero, size: toSize)
            let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: fromImageBounds, toCenterOfRect: toImageBounds)
            
            transformedQuad = transformedQuad.applyTransforms([rotationTransform, translationTransform])
        }
        
        return transformedQuad
    }
    
    // Convenience functions
    
    /// Sorts the given `CGPoints` based on their y value.
    /// - Parameters:
    ///   - points: The poinmts to sort.
    /// - Returns: The points sorted based on their y value.
    private func sortPointsByYValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.y < point2.y
        }
    }
    
    /// Sorts the given `CGPoints` based on their x value.
    /// - Parameters:
    ///   - points: The points to sort.
    /// - Returns: The points sorted based on their x value.
    private func sortPointsByXValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.x < point2.x
        }
    }
}

extension Quadrilateral {
    
    /// Converts the current to the cartesian coordinate system (where 0 on the y axis is at the bottom).
    ///
    /// - Parameters:
    ///   - height: The height of the rect containing the quadrilateral.
    /// - Returns: The same quadrilateral in the cartesian corrdinate system.
    func toCartesian(withHeight height: CGFloat) -> Quadrilateral {
        let topLeft = self.topLeft.cartesian(withHeight: height)
        let topRight = self.topRight.cartesian(withHeight: height)
        let bottomRight = self.bottomRight.cartesian(withHeight: height)
        let bottomLeft = self.bottomLeft.cartesian(withHeight: height)
        
        return Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
}

extension Quadrilateral: Equatable {
    public static func == (lhs: Quadrilateral, rhs: Quadrilateral) -> Bool {
        return lhs.topLeft == rhs.topLeft && lhs.topRight == rhs.topRight && lhs.bottomRight == rhs.bottomRight && lhs.bottomLeft == rhs.bottomLeft
    }
}
protocol Transformable {
    
    /// Applies the given `CGAffineTransform`.
    ///
    /// - Parameters:
    ///   - t: The transform to apply
    /// - Returns: The same object transformed by the passed in `CGAffineTransform`.
    func applying(_ transform: CGAffineTransform) -> Self

}

extension Transformable {
    
    /// Applies multiple given transforms in the given order.
    ///
    /// - Parameters:
    ///   - transforms: The transforms to apply.
    /// - Returns: The same object transformed by the passed in `CGAffineTransform`s.
    func applyTransforms(_ transforms: [CGAffineTransform]) -> Self {
        
        var transformableObject = self
        
        transforms.forEach { (transform) in
            transformableObject = transformableObject.applying(transform)
        }
        
        return transformableObject
    }
    
}
extension CGPoint {
    
    /// Returns a rectangle of a given size surounding the point.
    ///
    /// - Parameters:
    ///   - size: The size of the rectangle that should surround the points.
    /// - Returns: A `CGRect` instance that surrounds this instance of `CGpoint`.
    func surroundingSquare(withSize size: CGFloat) -> CGRect {
        return CGRect(x: x - size / 2.0, y: y - size / 2.0, width: size, height: size)
    }
    
    /// Checks wether this point is within a given distance of another point.
    ///
    /// - Parameters:
    ///   - delta: The minimum distance to meet for this distance to return true.
    ///   - point: The second point to compare this instance with.
    /// - Returns: True if the given `CGPoint` is within the given distance of this instance of `CGPoint`.
    func isWithin(delta: CGFloat, ofPoint point: CGPoint) -> Bool {
        return (abs(x - point.x) <= delta) && (abs(y - point.y) <= delta)
    }
    
    /// Returns the same `CGPoint` in the cartesian coordinate system.
    ///
    /// - Parameters:
    ///   - height: The height of the bounds this points belong to, in the current coordinate system.
    /// - Returns: The same point in the cartesian coordinate system.
    func cartesian(withHeight height: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: height - y)
    }
    
    /// Returns the distance between two points
    func distanceTo(point: CGPoint) -> CGFloat {
        return hypot((self.x - point.x), (self.y - point.y))
    }
    
    /// Returns the closest corner from the point
    func closestCornerFrom(quad: Quadrilateral) -> CornerPosition {
        var smallestDistance = distanceTo(point: quad.topLeft)
        var closestCorner = CornerPosition.topLeft
        
        if distanceTo(point: quad.topRight) < smallestDistance {
            smallestDistance = distanceTo(point: quad.topRight)
            closestCorner = .topRight
        }
        
        if distanceTo(point: quad.bottomRight) < smallestDistance {
            smallestDistance = distanceTo(point: quad.bottomRight)
            closestCorner = .bottomRight
        }
        
        if distanceTo(point: quad.bottomLeft) < smallestDistance {
            smallestDistance = distanceTo(point: quad.bottomLeft)
            closestCorner = .bottomLeft
        }
        
        return closestCorner
    }
    
}
extension Array where Element == Quadrilateral {
    
    /// Finds the biggest rectangle within an array of `Quadrilateral` objects.
    func biggest() -> Quadrilateral? {
        let biggestRectangle = self.max(by: { (rect1, rect2) -> Bool in
            return rect1.perimeter < rect2.perimeter
        })
        
        return biggestRectangle
    }
    
}
extension CGAffineTransform {
    
    /// Convenience function to easily get a scale `CGAffineTransform` instance.
    ///
    /// - Parameters:
    ///   - fromSize: The size that needs to be transformed to fit (aspect fill) in the other given size.
    ///   - toSize: The size that should be matched by the `fromSize` parameter.
    /// - Returns: The transform that will make the `fromSize` parameter fir (aspect fill) inside the `toSize` parameter.
    static func scaleTransform(forSize fromSize: CGSize, aspectFillInSize toSize: CGSize) -> CGAffineTransform {
        let scale = max(toSize.width / fromSize.width, toSize.height / fromSize.height)
        return CGAffineTransform(scaleX: scale, y: scale)
    }
    
    /// Convenience function to easily get a translate `CGAffineTransform` instance.
    ///
    /// - Parameters:
    ///   - fromRect: The rect which center needs to be translated to the center of the other passed in rect.
    ///   - toRect: The rect that should be matched.
    /// - Returns: The transform that will translate the center of the `fromRect` parameter to the center of the `toRect` parameter.
    static func translateTransform(fromCenterOfRect fromRect: CGRect, toCenterOfRect toRect: CGRect) -> CGAffineTransform {
        let translate = CGPoint(x: toRect.midX - fromRect.midX, y: toRect.midY - fromRect.midY)
        return CGAffineTransform(translationX: translate.x, y: translate.y)
    }
        
}
/// Simple enum to keep track of the position of the corners of a quadrilateral.
enum CornerPosition {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}
enum AddResult {
    case showAndAutoScan
    case showOnly
}

/// `RectangleFeaturesFunnel` is used to improve the confidence of the detected rectangles.
/// Feed rectangles to a `RectangleFeaturesFunnel` instance, and it will call the completion block with a rectangle whose confidence is high enough to be displayed.
final class RectangleFeaturesFunnel {
    
    /// `RectangleMatch` is a class used to assign matching scores to rectangles.
    private final class RectangleMatch: NSObject {
        /// The rectangle feature object associated to this `RectangleMatch` instance.
        let rectangleFeature: Quadrilateral
        
        /// The score to indicate how strongly the rectangle of this instance matches other recently added rectangles.
        /// A higher score indicates that many recently added rectangles are very close to the rectangle of this instance.
        var matchingScore = 0
        
        init(rectangleFeature: Quadrilateral) {
            self.rectangleFeature = rectangleFeature
        }
        
        override var description: String {
            return "Matching score: \(matchingScore) - Rectangle: \(rectangleFeature)"
        }
        
        /// Whether the rectangle of this instance is within the distance of the given rectangle.
        ///
        /// - Parameters:
        ///   - rectangle: The rectangle to compare the rectangle of this instance with.
        ///   - threshold: The distance used to determinate if the rectangles match in pixels.
        /// - Returns: True if both rectangles are within the given distance of each other.
        func matches(_ rectangle: Quadrilateral, withThreshold threshold: CGFloat) -> Bool {
            return rectangleFeature.isWithin(threshold, ofRectangleFeature: rectangle)
        }
    }
    
    /// The queue of last added rectangles. The first rectangle is oldest one, and the last rectangle is the most recently added one.
    private var rectangles = [RectangleMatch]()
    
    /// The maximum number of rectangles to compare newly added rectangles with. Determines the maximum size of `rectangles`. Increasing this value will impact performance.
    let maxNumberOfRectangles = 8
    
    /// The minimum number of rectangles needed to start making comparaisons and determining which rectangle to display. This value should always be inferior than `maxNumberOfRectangles`.
    /// A higher value will delay the first time a rectangle is displayed.
    let minNumberOfRectangles = 3
    
    /// The value in pixels used to determine if two rectangle match or not. A higher value will prevent displayed rectangles to be refreshed. On the opposite, a smaller value will make new rectangles be displayed constantly.
    let matchingThreshold: CGFloat = 40.0
    
    /// The minumum number of matching rectangles (within the `rectangle` queue), to be confident enough to display a rectangle.
    let minNumberOfMatches = 3
    
    /// The number of similar rectangles that need to be found to auto scan.
    let autoScanThreshold = 35
    
    /// The number of times the rectangle has passed the threshold to be auto-scanned
    var currentAutoScanPassCount = 0
    
    /// The value in pixels used to determine if a rectangle is accurate enough to be auto scanned.
    /// A higher value means the auto scan is quicker, but the rectangle will be less accurate. On the other hand, the lower the value, the longer it'll take for the auto scan, but it'll be way more accurate
    var autoScanMatchingThreshold: CGFloat = 6.0
    
    /// Add a rectangle to the funnel, and if a new rectangle should be displayed, the completion block will be called.
    /// The algorithm works the following way:
    /// 1. Makes sure that the funnel has been fed enough rectangles
    /// 2. Removes old rectangles if needed
    /// 3. Compares all of the recently added rectangles to find out which one match each other
    /// 4. Within all of the recently added rectangles, finds the "best" one (@see `bestRectangle(withCurrentlyDisplayedRectangle:)`)
    /// 5. If the best rectangle is different than the currently displayed rectangle, informs the listener that a new rectangle should be displayed
    ///     5a. The currentAutoScanPassCount is incremented every time a new rectangle is displayed. If it passes the autoScanThreshold, we tell the listener to scan the document.
    /// - Parameters:
    ///   - rectangleFeature: The rectangle to feed to the funnel.
    ///   - currentRectangle: The currently displayed rectangle. This is used to avoid displaying very close rectangles.
    ///   - completion: The completion block called when a new rectangle should be displayed.
    func add(_ rectangleFeature: Quadrilateral, currentlyDisplayedRectangle currentRectangle: Quadrilateral?, completion: (AddResult, Quadrilateral) -> Void) {
        let rectangleMatch = RectangleMatch(rectangleFeature: rectangleFeature)
        rectangles.append(rectangleMatch)
        
        guard rectangles.count >= minNumberOfRectangles else {
            return
        }
        
        if rectangles.count > maxNumberOfRectangles {
            rectangles.removeFirst()
        }
        
        updateRectangleMatches()
        
        guard let bestRectangle = bestRectangle(withCurrentlyDisplayedRectangle: currentRectangle) else {
            return
        }
        
        if let previousRectangle = currentRectangle,
            bestRectangle.rectangleFeature.isWithin(autoScanMatchingThreshold, ofRectangleFeature: previousRectangle) {
            currentAutoScanPassCount += 1
            if currentAutoScanPassCount > autoScanThreshold {
                currentAutoScanPassCount = 0
                completion(AddResult.showAndAutoScan, bestRectangle.rectangleFeature)
            }
        } else {
            completion(AddResult.showOnly, bestRectangle.rectangleFeature)
        }
    }
    
    /// Determines which rectangle is best to displayed.
    /// The criteria used to find the best rectangle is its matching score.
    /// If multiple rectangles have the same matching score, we use a tie breaker to find the best rectangle (@see breakTie(forRectangles:)).
    /// Parameters:
    ///   - currentRectangle: The currently displayed rectangle. This is used to avoid displaying very close rectangles.
    /// Returns: The best rectangle to display given the current history.
    private func bestRectangle(withCurrentlyDisplayedRectangle currentRectangle: Quadrilateral?) -> RectangleMatch? {
        var bestMatch: RectangleMatch?
        guard !rectangles.isEmpty else { return nil }
        rectangles.reversed().forEach { (rectangle) in
            guard let best = bestMatch else {
                bestMatch = rectangle
                return
            }
            
            if rectangle.matchingScore > best.matchingScore {
                bestMatch = rectangle
                return
            } else if rectangle.matchingScore == best.matchingScore {
                guard let currentRectangle = currentRectangle else {
                    return
                }
                
                bestMatch = breakTie(between: best, rect2: rectangle, currentRectangle: currentRectangle)
            }
        }
        
        return bestMatch
    }
    
    /// Breaks a tie between two rectangles to find out which is best to display.
    /// The first passed rectangle is returned if no other criteria could be used to break the tie.
    /// If the first passed rectangle (rect1) is close to the currently displayed rectangle, we pick it.
    /// Otherwise if the second passed rectangle (rect2) is close to the currently displayed rectangle, we pick this one.
    /// Finally, if none of the passed in rectangles are close to the currently displayed rectangle, we arbitrary pick the first one.
    /// - Parameters:
    ///   - rect1: The first rectangle to compare.
    ///   - rect2: The second rectangle to compare.
    ///   - currentRectangle: The currently displayed rectangle. This is used to avoid displaying very close rectangles.
    /// - Returns: The best rectangle to display between two rectangles with the same matching score.
    private func breakTie(between rect1: RectangleMatch, rect2: RectangleMatch, currentRectangle: Quadrilateral) -> RectangleMatch {
        if rect1.rectangleFeature.isWithin(matchingThreshold, ofRectangleFeature: currentRectangle) {
            return rect1
        } else if rect2.rectangleFeature.isWithin(matchingThreshold, ofRectangleFeature: currentRectangle) {
            return rect2
        }
        
        return rect1
    }
    
    /// Loops through all of the rectangles of the queue, and gives them a score depending on how many they match. @see `RectangleMatch.matchingScore`
    private func updateRectangleMatches() {
        resetMatchingScores()
        guard !rectangles.isEmpty else { return }
        for (i, currentRect) in rectangles.enumerated() {
            for (j, rect) in rectangles.enumerated() {
                if j > i && currentRect.matches(rect.rectangleFeature, withThreshold: matchingThreshold) {
                    currentRect.matchingScore += 1
                    rect.matchingScore += 1
                }
            }
        }
    }
    
    /// Resets the matching score of all of the rectangles in the queue to 0
    private func resetMatchingScores() {
        guard !rectangles.isEmpty else { return }
        for rectangle in rectangles {
            rectangle.matchingScore = 1
        }
    }
    
}
/// The `QuadrilateralView` is a simple `UIView` subclass that can draw a quadrilateral, and optionally edit it.
final class QuadrilateralView: UIView {
    
    private let quadLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = Asset.colorApp.color.cgColor
        layer.lineWidth = 1.0
        layer.opacity = 1.0
        layer.isHidden = true
        
        return layer
    }()
    
    /// We want the corner views to be displayed under the outline of the quadrilateral.
    /// Because of that, we need the quadrilateral to be drawn on a UIView above them.
    private let quadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The quadrilateral drawn on the view.
    private(set) var quad: Quadrilateral?
    
    public var editable = false {
        didSet {
            cornerViews(hidden: !editable)
            quadLayer.fillColor = editable ? UIColor(white: 0.0, alpha: 0.6).cgColor : UIColor(white: 1.0, alpha: 0.5).cgColor
            guard let quad = quad else {
                return
            }
            drawQuad(quad, animated: false)
            layoutCornerViews(forQuad: quad)
        }
    }

    /// Set stroke color of image rect and coner.
    public var strokeColor: CGColor? {
        didSet {
            quadLayer.strokeColor = strokeColor
            topLeftCornerView.strokeColor = strokeColor
            topRightCornerView.strokeColor = strokeColor
            bottomRightCornerView.strokeColor = strokeColor
            bottomLeftCornerView.strokeColor = strokeColor
        }
    }
    
    private var isHighlighted = false {
        didSet (oldValue) {
            guard oldValue != isHighlighted else {
                return
            }
            quadLayer.fillColor = isHighlighted ? UIColor.clear.cgColor : UIColor(white: 0.0, alpha: 0.6).cgColor
            isHighlighted ? bringSubviewToFront(quadView) : sendSubviewToBack(quadView)
        }
    }
    
    private lazy var topLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topLeft)
    }()
    
    private lazy var topRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topRight)
    }()
    
    private lazy var bottomRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomRight)
    }()
    
    private lazy var bottomLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomLeft)
    }()
    
    private let highlightedCornerViewSize = CGSize(width: 75.0, height: 75.0)
    private let cornerViewSize = CGSize(width: 20.0, height: 20.0)
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(quadView)
        setupCornerViews()
        setupConstraints()
        quadView.layer.addSublayer(quadLayer)
    }
    
    private func setupConstraints() {
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: topAnchor),
            quadView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            trailingAnchor.constraint(equalTo: quadView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints)
    }
    
    private func setupCornerViews() {
        addSubview(topLeftCornerView)
        addSubview(topRightCornerView)
        addSubview(bottomRightCornerView)
        addSubview(bottomLeftCornerView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard quadLayer.frame != bounds else {
            return
        }
        
        quadLayer.frame = bounds
        if let quad = quad {
            drawQuadrilateral(quad: quad, animated: false)
        }
    }
    
    // MARK: - Drawings
    
    /// Draws the passed in quadrilateral.
    ///
    /// - Parameters:
    ///   - quad: The quadrilateral to draw on the view. It should be in the coordinates of the current `QuadrilateralView` instance.
    func drawQuadrilateral(quad: Quadrilateral, animated: Bool) {
        self.quad = quad
        drawQuad(quad, animated: animated)
        if editable {
            cornerViews(hidden: false)
            layoutCornerViews(forQuad: quad)
        }
    }
    
    private func drawQuad(_ quad: Quadrilateral, animated: Bool) {
        var path = quad.path
        
        if editable {
            path = path.reversing()
            let rectPath = UIBezierPath(rect: bounds)
            path.append(rectPath)
        }
        
        if animated == true {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = 0.2
            quadLayer.add(pathAnimation, forKey: "path")
        }
        
        quadLayer.path = path.cgPath
        quadLayer.isHidden = false
    }
    
    private func layoutCornerViews(forQuad quad: Quadrilateral) {
        topLeftCornerView.center = quad.topLeft
        topRightCornerView.center = quad.topRight
        bottomLeftCornerView.center = quad.bottomLeft
        bottomRightCornerView.center = quad.bottomRight
    }
    
    func removeQuadrilateral() {
        quadLayer.path = nil
        quadLayer.isHidden = true
    }
    
    // MARK: - Actions
    
    func moveCorner(cornerView: EditScanCornerView, atPoint point: CGPoint) {
        guard let quad = quad else {
            return
        }
        
        let validPoint = self.validPoint(point, forCornerViewOfSize: cornerView.bounds.size, inView: self)
        
        cornerView.center = validPoint
        let updatedQuad = update(quad, withPosition: validPoint, forCorner: cornerView.position)
        
        self.quad = updatedQuad
        drawQuad(updatedQuad, animated: false)
    }
    
    func highlightCornerAtPosition(position: CornerPosition, with image: UIImage) {
        guard editable else {
            return
        }
        isHighlighted = true
        
        let cornerView = cornerViewForCornerPosition(position: position)
        guard cornerView.isHighlighted == false else {
            cornerView.highlightWithImage(image)
            return
        }

        let origin = CGPoint(x: cornerView.frame.origin.x - (highlightedCornerViewSize.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y - (highlightedCornerViewSize.height - cornerViewSize.height) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: highlightedCornerViewSize)
        cornerView.highlightWithImage(image)
    }
    
    func resetHighlightedCornerViews() {
        isHighlighted = false
        resetHighlightedCornerViews(cornerViews: [topLeftCornerView, topRightCornerView, bottomLeftCornerView, bottomRightCornerView])
    }
    
    private func resetHighlightedCornerViews(cornerViews: [EditScanCornerView]) {
        cornerViews.forEach { (cornerView) in
            resetHightlightedCornerView(cornerView: cornerView)
        }
    }
    
    private func resetHightlightedCornerView(cornerView: EditScanCornerView) {
        cornerView.reset()
        let origin = CGPoint(x: cornerView.frame.origin.x + (cornerView.frame.size.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y + (cornerView.frame.size.height - cornerViewSize.width) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: cornerViewSize)
        cornerView.setNeedsDisplay()
    }
    
    // MARK: Validation
    
    /// Ensures that the given point is valid - meaning that it is within the bounds of the passed in `UIView`.
    ///
    /// - Parameters:
    ///   - point: The point that needs to be validated.
    ///   - cornerViewSize: The size of the corner view representing the given point.
    ///   - view: The view which should include the point.
    /// - Returns: A new point which is within the passed in view.
    private func validPoint(_ point: CGPoint, forCornerViewOfSize cornerViewSize: CGSize, inView view: UIView) -> CGPoint {
        var validPoint = point
        
        if point.x > view.bounds.width {
            validPoint.x = view.bounds.width
        } else if point.x < 0.0 {
            validPoint.x = 0.0
        }
        
        if point.y > view.bounds.height {
            validPoint.y = view.bounds.height
        } else if point.y < 0.0 {
            validPoint.y = 0.0
        }
        
        return validPoint
    }
    
    // MARK: - Convenience
    
    private func cornerViews(hidden: Bool) {
        topLeftCornerView.isHidden = hidden
        topRightCornerView.isHidden = hidden
        bottomRightCornerView.isHidden = hidden
        bottomLeftCornerView.isHidden = hidden
    }
    
    private func update(_ quad: Quadrilateral, withPosition position: CGPoint, forCorner corner: CornerPosition) -> Quadrilateral {
        var quad = quad
        
        switch corner {
        case .topLeft:
            quad.topLeft = position
        case .topRight:
            quad.topRight = position
        case .bottomRight:
            quad.bottomRight = position
        case .bottomLeft:
            quad.bottomLeft = position
        }
        
        return quad
    }
    
    func cornerViewForCornerPosition(position: CornerPosition) -> EditScanCornerView {
        switch position {
        case .topLeft:
            return topLeftCornerView
        case .topRight:
            return topRightCornerView
        case .bottomLeft:
            return bottomLeftCornerView
        case .bottomRight:
            return bottomRightCornerView
        }
    }
}

/// A UIView used by corners of a quadrilateral that is aware of its position.
final class EditScanCornerView: UIView {
    
    let position: CornerPosition
    
    /// The image to display when the corner view is highlighted.
    private var image: UIImage?
    private(set) var isHighlighted = false
    
    private lazy var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        return layer
    }()

    /// Set stroke color of coner layer
    public var strokeColor: CGColor? {
        didSet {
            circleLayer.strokeColor = strokeColor
        }
    }
    
    init(frame: CGRect, position: CornerPosition) {
        self.position = position
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        clipsToBounds = true
        layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bezierPath = UIBezierPath(ovalIn: rect.insetBy(dx: circleLayer.lineWidth, dy: circleLayer.lineWidth))
        circleLayer.frame = rect
        circleLayer.path = bezierPath.cgPath
        
        image?.draw(in: rect)
    }
    
    func highlightWithImage(_ image: UIImage) {
        isHighlighted = true
        self.image = image
        self.setNeedsDisplay()
    }
    
    func reset() {
        isHighlighted = false
        image = nil
        setNeedsDisplay()
    }
    
}

