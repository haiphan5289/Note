
//
//  
//  ListTextVC.swift
//  Note
//
//  Created by haiphan on 04/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class ListTextVC: UIViewController {
    
    // Add here outlets
    
    // Add here your view model
    private var viewModel: ListTextVM = ListTextVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension ListTextVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
