
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
    @IBOutlet weak var imgBg: UIImageView!
    
    // Add here your view model
    private var viewModel: TextVM = TextVM()
    private var previousFont: UIFont?
    private var previousBgColor: BackgroundColor.BgColorTypes?
    
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
        self.setupImageBg()
        
        self.textColor = textView.textColor ?? Asset.colorApp.color
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
                wSelf.textView.textColor = wSelf.textColor
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
        
        self.eventSaveTextColor
            .withLatestFrom(self.$eventPickColor, resultSelector:  { ( type: $0, textColor: $1 ) } )
            .bind { [weak self] (type , textColor) in
                guard let wSelf = self else { return }
                
                switch type {
                case .cancel:
                    wSelf.textView.textColor = wSelf.textColor
                case .done:
                    wSelf.textView.textColor = textColor
                    wSelf.textColor = textColor
                }
                
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
        
        self.eventUpdateBgColor.asObservable().bind { [weak self] type in
            guard let wSelf = self else { return }
            wSelf.updateBgColorWhenDone(bgColorType: type)
        }.disposed(by: disposeBag)
        
        self.eventPickBgColor.asObservable().bind { [weak self] type in
            guard let wSelf = self else { return }
            
            switch type {
            case .cancel:
                wSelf.resetBgColor()
                if let pre = wSelf.previousBgColor {
                    wSelf.updateBgColorWhenDone(bgColorType: pre)
                }
                
            case .done( let bgColorType):
                wSelf.previousBgColor = bgColorType
                wSelf.updateBgColorWhenDone(bgColorType: bgColorType)
            }
            
        }.disposed(by: disposeBag)
    
    }
    
    private func updateBgColorWhenDone(bgColorType: BackgroundColor.BgColorTypes) {
        switch bgColorType {
        case .gradient(let list ):
            self.removeCAGradientLayer()
            self.textView.backgroundColor = .clear
            self.textView.applyGradient(withColours: list, gradientOrientation: .vertical)
        case .colors(let color):
            self.removeCAGradientLayer()
            if let color = color {
                self.imgBg.isHidden = true
                self.textView.backgroundColor = color
            }
        case .images(let img):
            self.removeCAGradientLayer()
            if let img = img {
                self.updateImgBg(img: img)
            }
        }
    }
    
    private func resetBgColor() {
        self.removeCAGradientLayer()
        self.textView.backgroundColor = .white
        self.imgBg.isHidden = true
    }
    
    private func removeCAGradientLayer() {
        guard let subplayers = self.textView.layer.sublayers else {
            return
        }
        
        for sublayer in subplayers where sublayer is CAGradientLayer {
            sublayer.removeFromSuperlayer()
        }
    }
    
    private func updateImgBg(img: UIImage) {
        self.textView.backgroundColor = UIColor.clear
        self.imgBg.image = img
        self.imgBg.isHidden = false
    }
    
    private func setupImageBg() {
        self.imgBg.contentMode = .scaleToFill
        self.imgBg.tag = Constant.tagImage
        self.imgBg.clipsToBounds = true
        self.imgBg.layer.cornerRadius = ConstantCommon.shared.radiusViewDialog
        self.imgBg.isHidden = true
        self.view.addSubview( self.imgBg)
        self.view.sendSubviewToBack(self.imgBg)
        self.imgBg.snp.makeConstraints { (make) in
            make.edges.equalTo(self.textView)
        }
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
