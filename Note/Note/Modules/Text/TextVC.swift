
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
        static let heightTextView: CGFloat = 300
        static let widthTextView: CGFloat = 0.9
        static let topContraintTextView: CGFloat = 10
        static let botContraintTextView: CGFloat = 10
        static let tagImage: Int = 99
    }
    
    // Add here outlets
    @IBOutlet weak var textView: UITextView!
    
    // Add here your view model
    private var viewModel: TextVM = TextVM()
    private var previousFont: UIFont?
    private var previousColor: UIColor = Asset.colorApp.color
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.centerVertically()
    }
    
}
extension TextVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        textView.clipsToBounds = true
        textView.layer.cornerRadius = ConstantCommon.shared.radiusViewDialog
        textView.centerVertically()
        textView.becomeFirstResponder()
        previousFont = textView.font
        self.eventUpdateFontStyleView.accept(textView.font ?? ConstantCommon.shared.fontDefault)
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        
        //This is reason that use delay because Text will jump to top
        self.eventFont.asObservable()
            .delay(.milliseconds(200), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] status in
            guard let wSelf = self else { return }
            switch status {
            case .update(let font): wSelf.textView.font = font
            case .cancel:
                if let f = wSelf.previousFont {
                    wSelf.textView.font = f
                }
            case .done(let font):
                wSelf.textView.font = font
                wSelf.previousFont = font
                wSelf.eventUpdateFontStyleView.accept(font)
            }
            wSelf.textView.centerVertically()
        }.disposed(by: disposeBag)
        
        self.$eventPickColor.asObservable().bind { [weak self] color in
            guard let wSelf = self else { return }
            wSelf.textView.textColor = color
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
            wSelf.textView.centerVertically()
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
        
        self.eventUpdateBgColor.asObservable().bind { [weak self] img in
            guard let wSelf = self else { return }
            
            wSelf.view.subviews.forEach { v in
                if v.tag == Constant.tagImage {
                    v.removeFromSuperview()
                }
            }

            let img = UIImageView(image: img.resizeImage(wSelf.textView.bounds.size))
            img.contentMode = .scaleToFill
            img.tag = Constant.tagImage
            img.clipsToBounds = true
            img.layer.cornerRadius = ConstantCommon.shared.radiusViewDialog
            wSelf.textView.backgroundColor = UIColor.clear
            wSelf.view.addSubview( img)
            wSelf.view.sendSubviewToBack(img)
            img.snp.makeConstraints { (make) in
                make.edges.equalTo(wSelf.textView)
            }
        }.disposed(by: disposeBag)
    
    }
    
    private func textViewHideKeyboard() {
        self.textView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.height.equalTo(Constant.heightTextView)
        }
    }
    
    private func textViewShowKeyboard(height: CGFloat) {
        self.textView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Constant.topContraintTextView)
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(height + BaseNavigationHeader.Constant.heightViewStyle + Constant.botContraintTextView)
        }
    }
    
    private func textViewShowListFont() {
        self.textView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Constant.topContraintTextView)
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(BaseNavigationHeader.Constant.heightViewListFont + Constant.botContraintTextView)
        }
    }
}
