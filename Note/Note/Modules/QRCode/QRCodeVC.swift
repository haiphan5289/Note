
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

class QRCodeVC: UIViewController {
    
    // Add here outlets
    
    // Add here your view model
    private var viewModel: QRCodeVM = QRCodeVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension QRCodeVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
