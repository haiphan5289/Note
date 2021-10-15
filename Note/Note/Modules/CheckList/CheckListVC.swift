
//
//  
//  CheckListVC.swift
//  Note
//
//  Created by haiphan on 14/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class CheckListVC: BaseNavigationHeader {
    
    struct ConstantList {
        static let heightTf: CGFloat = 50
    }
    
    // Add here outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tvInput: UITextView!
    @IBOutlet weak var heightTextInput: NSLayoutConstraint!
    
    // Add here your view model
    private var viewModel: CheckListVM = CheckListVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension CheckListVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        self.tfTitle.becomeFirstResponder()
        self.tfTitle.placeholder = L10n.CheckList.enterTitle
        self.tfTitle.textColor = Asset.textColorApp.color
        
        self.tvInput.text = L10n.CheckList.enterCheckList
        self.tvInput.textColor = Asset.disableHome.color
        
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.eventStatusKeyboard.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            if stt == .hide {
                wSelf.tfTitle.resignFirstResponder()
            } else {
                wSelf.tfTitle.becomeFirstResponder()
            }
        }.disposed(by: disposeBag)
        
        self.eventHeightKeyboard.asObservable().bind { [weak self] h in
            guard let wSelf = self else { return }
            if h <= 0 {
                wSelf.textViewHideKeyboard()
            } else {
                wSelf.textViewShowKeyboard(height: h)
            }
        }.disposed(by: disposeBag)
        
        self.eventShowListFontView.asObservable().bind { [weak self] hide in
            guard let wSelf = self else { return }
            
            if hide {
                wSelf.textViewHideKeyboard()
            } else {
                wSelf.textViewShowListFont()
            }
            
        }.disposed(by: disposeBag)
        
        self.tvInput.rx.didBeginEditing.asObservable().bind { [weak self] _ in
            guard let wSelf = self else { return }
            
            if wSelf.tvInput.textColor == Asset.disableHome.color {
                wSelf.tvInput.text = nil
                wSelf.tvInput.textColor = Asset.textColorApp.color
            }
            
        }.disposed(by: disposeBag)
        
        self.tvInput.rx.didChange.asObservable().bind { [weak self] _ in
            guard let wSelf = self else { return }
            
            wSelf.heightTextInput.constant = (wSelf.tvInput.contentSize.height > ConstantList.heightTf) ?  wSelf.tvInput.contentSize.height : ConstantList.heightTf
            
        }.disposed(by: disposeBag)
    }
    
    private func textViewHideKeyboard() {
        self.contentView.removeConstraints()
        self.contentView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.height.equalTo(Constant.heightTextView)
        }
        self.stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func textViewShowKeyboard(height: CGFloat) {
        self.contentView.removeConstraints()
        self.contentView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Constant.topContraintTextView)
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(height + BaseNavigationHeader.Constant.heightViewStyle + Constant.botContraintTextView)
        }
        self.stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func textViewShowListFont() {
        self.contentView.removeConstraints()
        self.contentView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Constant.topContraintTextView)
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(BaseNavigationHeader.Constant.heightViewListFont + Constant.botContraintTextView)
        }
        self.stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
