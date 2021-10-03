
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

class TextVC: BaseNavigationHeader {
    
    struct Constant {
        static let heightViewStyle: CGFloat = 50
    }
    
    // Add here outlets
    @IBOutlet weak var textView: UITextView!
    private let configStyle: ConfigStyle = ConfigStyle.loadXib()
    // Add here your view model
    private var viewModel: TextVM = TextVM()
//    private var heightConstraint: Constraint? = nil
    
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
        textView.centerVertically()
        
        self.view.addSubview(self.configStyle)
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.navigationItemView.actionItem = { [weak self] type in
            guard let wSelf = self else { return }
            switch type {
            case .close: wSelf.navigationController?.popViewController(animated: true)
            default: break
            }
        }
        
        self.textView.rx.didChange.asObservable().bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.textView.centerVertically()
        }.disposed(by: disposeBag)
        
        self.eventHeightKeyboard.asObservable().startWith(0).bind { [weak self] h in
            guard let wSelf = self else { return }
            ( h > 0 ) ? wSelf.setupConfigStyleWHaveKeyboard(height: h) : wSelf.setupConfigStyleWithoutKeyboard()
        }.disposed(by: disposeBag)
    
    }
    
    private func setupConfigStyleWithoutKeyboard() {
        self.configStyle.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(Constant.heightViewStyle + ConstantCommon.shared.getHeightSafeArea(type: .bottom))
        }
    }
    
    private func setupConfigStyleWHaveKeyboard(height: CGFloat) {
        self.configStyle.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(Constant.heightViewStyle)
            make.bottom.equalToSuperview().inset(height)
        }
    }
}
