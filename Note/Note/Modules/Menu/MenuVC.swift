
//
//  
//  MenuVC.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class MenuVC: UIViewController {
    
    // Add here outlets
    
    // Add here your view model
    private var viewModel: MenuVM = MenuVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension MenuVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
