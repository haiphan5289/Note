
//
//  
//  HomeVC.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class HomeVC: UIViewController {
    
    struct Constant {
        static let distanceFromTopTabbar: CGFloat = 20
        static let heightAddNoteView: CGFloat = 50
    }
    
    // Add here outlets
    // Add here your view model
    private var viewModel: HomeVM = HomeVM()
    private let vAddNote: AddNote = AddNote.loadXib()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension HomeVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        if let height = self.tabBarController?.tabBar.frame.height {
            self.view.addSubview(vAddNote)
            self.vAddNote.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(height - Constant.distanceFromTopTabbar)
                make.height.equalTo(Constant.heightAddNoteView)
            }
        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
