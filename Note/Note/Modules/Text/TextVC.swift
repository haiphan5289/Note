
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
    

    
    // Add here outlets
    @IBOutlet weak var textView: UITextView!
    
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
        textView.becomeFirstResponder()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        
        self.eventFont.asObservable().bind { [weak self] font in
            guard let wSelf = self else { return }
            wSelf.textView.font = font
            wSelf.textView.centerVertically()
        }.disposed(by: disposeBag)
        
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
        
        self.eventStatusKeyboard.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            if stt == .hide {
                wSelf.textView.resignFirstResponder()
            } else {
                wSelf.textView.becomeFirstResponder()
            }
        }.disposed(by: disposeBag)
    
    }
}
