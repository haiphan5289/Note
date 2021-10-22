
//
//  
//  QRCodePageVC.swift
//  Note
//
//  Created by haiphan on 21/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import WeScan

class QRCodePageVC: UIViewController {
    
    enum QRViewcontroller: Int, CaseIterable {
        case qrCode, document
        
        var vc: UIViewController {
            return ImageScannerController()
        }
        
    }
    
    // Add here outlets
    private lazy var pageVC: UIPageViewController = {
        guard let p = self.children.compactMap ({ $0 as? UIPageViewController }).first else {
            fatalError("Please Implement")
        }
        return p
    }()
    private var controllers: [UIViewController] = []
    
    // Add here your view model
    private var viewModel: QRCodePageVM = QRCodePageVM()
    private var index: Int = 0
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
}
extension QRCodePageVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.controllers = QRViewcontroller.allCases.map { $0.vc }
        self.pageVC.setViewControllers([QRViewcontroller.qrCode.vc], direction: .forward, animated: true, completion: nil)
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
    
    private func setPageController(type: QRViewcontroller) {
        let vc = self.controllers[type.rawValue]
        self.pageVC.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
}

