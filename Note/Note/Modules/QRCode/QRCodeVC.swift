
//
//  
//  QRCodeVC.swift
//  Note
//
//  Created by haiphan on 18/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import AVFoundation

class QRCodeVC: UIViewController {
    
    struct Constant {
        static let height: CGFloat = 250
    }
    
    // Add here outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var contentCamereDetectView: UIView!
    @IBOutlet weak var btCapture: UIButton!
    
    // Add here your view model
    private var viewModel: QRCodeVM = QRCodeVM()
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var qrCodeBounds: QRCodeView = QRCodeView.loadXib()
    private var contentQRCodeView: UIView = UIView(frame: .zero)
    private var frameCenter: CGRect = .zero
    private let showView: QRCodeTextView = QRCodeTextView.loadXib()
    private let cameraDetectObjectView: CameraDetectObject = CameraDetectObject.loadXib()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setupViewQR()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cameraDetectObjectView.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraDetectObjectView.updateFramePreview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopCapture()
        self.cameraDetectObjectView.stopRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
}
extension QRCodeVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        
        self.view.addSubview(showView)
        showView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(300)
        }
        self.showView.delegate = self
        self.showView.hideView()
        
        self.contentCamereDetectView.addSubview(self.cameraDetectObjectView)
        self.cameraDetectObjectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.cameraDetectObjectView.startStepUp()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btCapture.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            let vc = CropVC.createVC()
            vc.imageDocument = wSelf.cameraDetectObjectView.imageCropVC
            vc.rectCropView = wSelf.cameraDetectObjectView.rectCropView
            wSelf.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    private func setupViewQR() {
        let originX = (self.view.bounds.size.width / 2) -  (Constant.height / 2)
        let originY = (self.view.bounds.size.height / 2) -  (Constant.height / 2)
        let f = CGRect(x: originX, y: originY, width: Constant.height, height: Constant.height)
        self.contentQRCodeView.frame = f
        self.contentQRCodeView.clipsToBounds = true
        self.frameCenter = f
        self.contentQRCodeView.backgroundColor = .clear
        self.view.addSubview(self.contentQRCodeView)
        self.setupCamera()
        
        self.contentQRCodeView.addSubview(self.qrCodeBounds)
        self.qrCodeBounds.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCamera() {
        self.view.backgroundColor = UIColor.black
        
        // Setup Camera Capture
        self.captureSession = AVCaptureSession()

        // Get the default camera (there are normally between 2 to 4 camera 'devices' on iPhones)
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (self.captureSession.canAddInput(videoInput)) {
            self.captureSession.addInput(videoInput)
        } else {
            self.failed() // Simulator mostly
            return
        }

        // Now the camera is setup add a metadata output
        let metadataOutput = AVCaptureMetadataOutput()

        if (self.captureSession.canAddOutput(metadataOutput)) {
            self.captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr] // Also have things like Face, body, cats
        } else {
            self.failed()
            return
        }

        // Setup the UI to show the camera
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.frame = view.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.cameraView.layer.addSublayer(self.previewLayer)

//        self.qrCodeBounds.alpha = 0
//        self.cameraView.addSubview(self.qrCodeBounds)
        
        self.captureSession.startRunning()
    }
    
    private func stopCapture() {
        if (self.captureSession?.isRunning == true) {
            self.captureSession?.stopRunning()
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning failed", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(ac, animated: true)
        self.captureSession = nil
    }
    
    
    private func showQRCodeBounds(frame: CGRect?) {
        guard let frame = frame else { return }
        
        self.contentQRCodeView.layer.removeAllAnimations() // resets any previous animations and cancels the fade out
        self.contentQRCodeView.alpha = 1
        self.contentQRCodeView.frame = frame
    }
    
    private func showQRInCenter() {
        self.contentQRCodeView.frame = self.frameCenter
    }
    
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            self.showViewQRCode(text: stringValue)
            // Show bounds
            let qrCodeObject = self.previewLayer.transformedMetadataObject(for: readableObject)
            self.showQRCodeBounds(frame: qrCodeObject?.bounds)
        } else {
            
            UIView.animate(withDuration: 1, delay: 1, options: [], animations: { // after 1 second fade away
                self.showQRInCenter()
            })
        }
    }
    
    private func showViewQRCode(text: String) {
        self.showView.updateValue(text: text)
        self.showView.showView()
        self.contentQRCodeView.isHidden = true
    }
}
extension QRCodeVC: AVCaptureMetadataOutputObjectsDelegate {
    
}
extension QRCodeVC: QRCodeTextViewDelegate {
    func tapAction(action: QRCodeTextView.Action) {
        self.contentQRCodeView.isHidden = false
        self.showView.hideView()
        
        switch action {
        case .cancel: break
        case .done:
            let vc = TextVC.createVC()
            vc.textQRCode = self.showView.getTextQRCode()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
