
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
    @IBOutlet weak var imgBg: UIImageView!
    
    private var previousFont: UIFont?
    private var previousBgColor: BackgroundColor.BgColorTypes?
    private var bgColorModel: BgColorModel = BgColorModel.empty
    
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
        
        self.setupImageBg()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        //This is reason that use delay because Text will jump to top
        self.eventFont.asObservable()
            .delay(.milliseconds(200), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] status in
            guard let wSelf = self else { return }
            switch status {
            case .update(let fontName, let size):
                let f = UIFont(name: fontName, size: size)
                wSelf.tvInput.font = f
                wSelf.tfTitle.font = f
            case .cancel:
                if let f = wSelf.previousFont {
                    wSelf.tfTitle.font = f
                    wSelf.tvInput.font = f
                }
                wSelf.tfTitle.textColor = wSelf.textColor
                wSelf.tvInput.textColor = wSelf.textColor
            case .done(let fontName, let size, let indexFont, let indexStyle):
                let font = UIFont(name: fontName, size: size) ?? UIFont.mySystemFont(ofSize: 16)
                wSelf.tfTitle.font = font
                wSelf.tvInput.font = font
                wSelf.previousFont = font
                wSelf.bgColorModel.sizeFont = size
                wSelf.bgColorModel.textFont = fontName
                wSelf.bgColorModel.indexFont = indexFont
                wSelf.bgColorModel.indexFontStyle = indexStyle
                wSelf.eventUpdateFontStyleView.accept(font)
            }
        }.disposed(by: disposeBag)
        
        self.$eventPickColor.asObservable().bind { [weak self] color in
            guard let wSelf = self else { return }
            wSelf.tvInput.textColor = color
            wSelf.tfTitle.textColor = color
        }.disposed(by: disposeBag)
        
        self.eventSaveTextColor
            .withLatestFrom(self.$eventPickColor, resultSelector:  { ( type: $0, textColor: $1 ) } )
            .bind { [weak self] (type , textColor) in
                guard let wSelf = self else { return }
                
                switch type {
                case .cancel:
                    wSelf.tfTitle.textColor = wSelf.textColor
                    wSelf.tvInput.textColor = wSelf.textColor
                case .done:
                    wSelf.tfTitle.textColor = textColor
                    wSelf.tvInput.textColor = wSelf.textColor
                    wSelf.textColor = textColor
                    wSelf.bgColorModel.textColorString = textColor.hexString
                }
                
            }.disposed(by: disposeBag)
        
        self.navigationItemView.actionItem = { [weak self] type in
            guard let wSelf = self else { return }
            switch type {
            case .close: wSelf.navigationController?.popViewController(animated: true)
                
            case .done:
                wSelf.navigationController?.popViewController(animated: true, {
//                    let noteModel: NoteModel
//                    if let note = wSelf.noteModel {
//                        noteModel = NoteModel(noteType: .text, text: wSelf.textView.text, id: note.id, bgColorModel: wSelf.bgColorModel, updateDate: Date.convertDateToLocalTime())
//                    } else {
//                        noteModel = NoteModel(noteType: .text, text: wSelf.textView.text, id: Date.convertDateToLocalTime(), bgColorModel: wSelf.bgColorModel, updateDate: Date.convertDateToLocalTime())
//                    }
//                    RealmManager.shared.updateOrInsertConfig(model: noteModel)
                })
                
                
            default: break
            }
        }
        
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
    
    private func updateValueNote(note: NoteModel) {
        
        if let bgColorModel = note.bgColorModel, let type = bgColorModel.getBgColorType() {
            self.updateBgColorWhenDone(bgColorType: type)
        }
        
        if let bgColorModel = note.bgColorModel {
            self.tfTitle.font = bgColorModel.getFont()
            self.tvInput.font = bgColorModel.getFont()
            self.previousFont = bgColorModel.getFont()
            self.eventUpdateFontStyleView.accept(bgColorModel.getFont() ?? ConstantApp.shared.fontDefault)
        }
        
        if let bgColorModel = note.bgColorModel, let textColor = bgColorModel.textColorString {
            self.tfTitle.textColor = UIColor(hexString: textColor)
            self.tvInput.textColor = UIColor(hexString: textColor)
            self.textColor = UIColor(hexString: textColor) ?? Asset.textColorApp.color
        }
        
        self.bgColorModel = note.bgColorModel ?? BgColorModel.empty
//        self.textView.text = note.text
        self.noteModelBase = note
    }
    
    private func updateBgColorWhenDone(bgColorType: BackgroundColor.BgColorTypes) {
        switch bgColorType {
        case .gradient(let list ):
            self.removeCAGradientLayer()
            self.contentView.backgroundColor = .clear
            self.contentView.applyGradient(withColours: list.map { $0.covertToColor() }.compactMap{ $0 }, gradientOrientation: .vertical)
            self.bgColorModel = BgColorModel(color: nil, gradient: list, image: nil, textFont: self.bgColorModel.textFont,
                                             sizeFont: self.bgColorModel.sizeFont, indexFont: self.bgColorModel.indexFont,
                                             indexFontStyle: self.bgColorModel.indexFontStyle, textColorString: self.bgColorModel.textColorString)
        case .colors(let color):
            self.removeCAGradientLayer()
            if let color = color {
                self.imgBg.isHidden = true
                self.contentView.backgroundColor = color.covertToColor()
                self.bgColorModel = BgColorModel(color: color, gradient: nil, image: nil, textFont: self.bgColorModel.textFont,
                                                 sizeFont: self.bgColorModel.sizeFont, indexFont: self.bgColorModel.indexFont,
                                                 indexFontStyle: self.bgColorModel.indexFontStyle, textColorString: self.bgColorModel.textColorString)
            }
        case .images(let img):
            self.removeCAGradientLayer()
            if let img = img, let image = img.converToImage() {
                self.updateImgBg(img: image)
                self.bgColorModel = BgColorModel(color: nil, gradient: nil, image: img, textFont: self.bgColorModel.textFont,
                                                 sizeFont: self.bgColorModel.sizeFont, indexFont: self.bgColorModel.indexFont,
                                                 indexFontStyle: self.bgColorModel.indexFontStyle, textColorString: self.bgColorModel.textColorString)
            }
        }
    }
    
    private func updateImgBg(img: UIImage) {
        self.contentView.backgroundColor = UIColor.clear
        self.imgBg.image = img
        self.imgBg.isHidden = false
    }
    
    private func resetBgColor() {
        self.removeCAGradientLayer()
        self.contentView.backgroundColor = .white
        self.imgBg.isHidden = true
    }
    
    private func removeCAGradientLayer() {
        guard let subplayers = self.contentView.layer.sublayers else {
            return
        }
        
        for sublayer in subplayers where sublayer is CAGradientLayer {
            sublayer.removeFromSuperlayer()
        }
    }
    
    private func setupImageBg() {
        self.imgBg.contentMode = .scaleToFill
        self.imgBg.tag = Constant.tagImage
        self.imgBg.clipsToBounds = true
        self.imgBg.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        self.imgBg.isHidden = true
        self.view.addSubview( self.imgBg)
        self.view.sendSubviewToBack(self.imgBg)
        self.imgBg.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
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
