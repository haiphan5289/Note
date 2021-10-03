
//
//  
//  TextVC.swift
//  Note
//
//  Created by haiphan on 02/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class TextVC: UIViewController {
    
    // Add here outlets
    
    // Add here your view model
    private var viewModel: TextVM = TextVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension TextVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
