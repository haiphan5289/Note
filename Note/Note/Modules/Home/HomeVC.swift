
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
        static let totalBesidesArea: CGFloat = 75
        static let contraintBottomDropDownView: CGFloat = 10
    }
    
    // Add here outlets
    // Add here your view model
    private var viewModel: HomeVM = HomeVM()
    private let vAddNote: AddNote = AddNote.loadXib()
    private let vDropDown: DropdownView = DropdownView(frame: .zero)
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension HomeVC {
    
    private func setupUI() {
        vAddNote.delegate = self
        // Add here the setup for the UI
        if let height = self.tabBarController?.tabBar.frame.height {
            self.view.addSubview(vAddNote)
            self.vAddNote.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(height - Constant.distanceFromTopTabbar)
                make.height.equalTo(Constant.heightAddNoteView)
            }
        }
        
        let f: CGRect = CGRect(x: (self.view.frame.width / 2) - ((self.view.frame.width - Constant.totalBesidesArea) / 2),
                               y: self.view.frame.height - Constant.heightAddNoteView - ConstantCommon.shared.getHeightSafeArea(type: .bottom) - Constant.contraintBottomDropDownView,
                               width: self.view.frame.width - Constant.totalBesidesArea,
                               height: vDropDown.getHeightDropdown())
        vDropDown.frame = f
        vDropDown.isHidden = true
        self.view.addSubview(vDropDown)
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
extension HomeVC: AddNoteDelegate {
    func actionAddNote(status: AddNote.StatusAddNote) {
        switch status {
        case .open:
            self.vDropDown.isHidden = false
            var f = self.vDropDown.frame
            UIView.animate(withDuration: ConstantCommon.shared.timeAnimation) {
                f.origin.y -= self.vDropDown.getHeightDropdown()
                self.vDropDown.frame = f
            }
        default:
            var f = self.vDropDown.frame
            UIView.animate(withDuration: ConstantCommon.shared.timeAnimation) {
                f.origin.y += self.vDropDown.getHeightDropdown()
                self.vDropDown.frame = f
            } completion: { _ in
                self.vDropDown.isHidden = true
            }

        }
        
    }
}
