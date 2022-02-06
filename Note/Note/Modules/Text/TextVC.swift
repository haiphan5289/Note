
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

    var noteModel: NoteModel?
    var textQRCode: String?
    
    // Add here outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imgBg: UIImageView!
    
    // Add here your view model
    private var viewModel: TextVM = TextVM()
    private var previousFont: UIFont?
    private var previousBgColor: BackgroundColor.BgColorTypes?
    private var bgColorModel: BgColorModel = BgColorModel.empty
    private let calendarView: CalenDarPickerView = CalenDarPickerView.loadXib()
    private var reminder: CalendaModel?
    
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
        textView.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        textView.centerVertically()
        textView.becomeFirstResponder()
        previousFont = textView.font
        self.eventUpdateFontStyleView.accept(textView.font ?? ConstantApp.shared.fontDefault)
        self.setupImageBg()
        
        self.textColor = textView.textColor ?? Asset.colorApp.color
        
        if let note = self.noteModel {
            self.updateValueNote(note: note)
        } else {
            self.bgColorModel = BgColorModel.empty
        }
        
        if let t = self.textQRCode {
            self.textView.text = t
        }
        
        self.view.addSubview(self.calendarView)
        self.calendarView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.height.width.equalTo(CalenDarPickerView.Constant.heightView)
        }
        self.calendarView.hideView()
        self.calendarView.delegate = self
        if let note = self.noteModel, let r = note.reminder {
            self.calendarView.reloadValue(remider: r)
        }
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
                wSelf.textView.font = UIFont(name: fontName, size: size)
            case .cancel:
                if let f = wSelf.previousFont {
                    wSelf.textView.font = f
                }
                wSelf.textView.textColor = wSelf.textColor
            case .done(let fontName, let size, let indexFont, let indexStyle):
                let font = UIFont(name: fontName, size: size) ?? UIFont.mySystemFont(ofSize: 16)
                wSelf.textView.font = font
                wSelf.previousFont = font
                wSelf.bgColorModel.sizeFont = size
                wSelf.bgColorModel.textFont = fontName
                wSelf.bgColorModel.indexFont = indexFont
                wSelf.bgColorModel.indexFontStyle = indexStyle
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
                    wSelf.bgColorModel.textColorString = textColor.hexString
                }
                
            }.disposed(by: disposeBag)
        
        self.navigationItemView.actionItem = { [weak self] type in
            guard let wSelf = self else { return }
            switch type {
            case .close: wSelf.navigationController?.popViewController(animated: true)
            case .done:
                wSelf.removeQRCodeVC()
                
                wSelf.navigationController?.popViewController(animated: true, {
                    let noteModel: NoteModel
                    if let note = wSelf.noteModel {
                        noteModel = NoteModel(noteType: .text, text: wSelf.textView.text, id: note.id, bgColorModel: wSelf.bgColorModel,
                                              updateDate: Date.convertDateToLocalTime(), noteCheckList: nil, noteDrawModel: nil, notePhotoModel: nil, reminder: wSelf.reminder)
                    } else {
                        noteModel = NoteModel(noteType: .text, text: wSelf.textView.text, id: Date.convertDateToLocalTime(), bgColorModel: wSelf.bgColorModel,
                                              updateDate: Date.convertDateToLocalTime(), noteCheckList: nil, noteDrawModel: nil, notePhotoModel: nil, reminder: wSelf.reminder)
                        
                        if let r = wSelf.reminder, r.isReminder {
                            NoteManage.shared.pushLocal(day: r.day, identifierNotification: "\(noteModel.id ?? Date.convertDateToLocalTime())")
                        }
                    }
                    RealmManager.shared.updateOrInsertConfig(model: noteModel)
                })
            case .reminder:
                wSelf.calendarView.showView()
                
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
    
    private func removeQRCodeVC() {
        if var viewControllers = self.navigationController?.viewControllers
           {
            for (index, controller) in viewControllers.enumerated()
               {
                   if controller is QRCodeVC
                   {
                    viewControllers.remove(at: index)
                       self.navigationController?.viewControllers = viewControllers
                   }
               }
           }
    }
    
    private func updateValueNote(note: NoteModel) {
        
        if let bgColorModel = note.bgColorModel, let type = bgColorModel.getBgColorType() {
            self.updateBgColorWhenDone(bgColorType: type)
        }
        
        if let bgColorModel = note.bgColorModel {
            self.textView.font = bgColorModel.getFont()
            self.previousFont = bgColorModel.getFont()
            self.eventUpdateFontStyleView.accept(bgColorModel.getFont() ?? ConstantApp.shared.fontDefault)
        }
        
        if let bgColorModel = note.bgColorModel, let textColor = bgColorModel.textColorString {
            self.textView.textColor = UIColor(hexString: textColor)
            self.textColor = UIColor(hexString: textColor) ?? Asset.textColorApp.color
        }
        
        self.bgColorModel = note.bgColorModel ?? BgColorModel.empty
        self.textView.text = note.text
        self.noteModelBase = note
    }
    
    private func updateBgColorWhenDone(bgColorType: BackgroundColor.BgColorTypes) {
        switch bgColorType {
        case .gradient(let list ):
            NoteManage.shared.removeCAGradientLayer(view: self.textView)
            self.textView.backgroundColor = .clear
            self.textView.applyGradient(withColours: list.map { $0.covertToColor() }.compactMap{ $0 }, gradientOrientation: .vertical)
            self.bgColorModel = BgColorModel(color: nil, gradient: list, image: nil, textFont: self.bgColorModel.textFont,
                                             sizeFont: self.bgColorModel.sizeFont, indexFont: self.bgColorModel.indexFont,
                                             indexFontStyle: self.bgColorModel.indexFontStyle, textColorString: self.bgColorModel.textColorString)
        case .colors(let color):
            NoteManage.shared.removeCAGradientLayer(view: self.textView)
            if let color = color {
                self.imgBg.isHidden = true
                self.textView.backgroundColor = color.covertToColor()
                self.bgColorModel = BgColorModel(color: color, gradient: nil, image: nil, textFont: self.bgColorModel.textFont,
                                                 sizeFont: self.bgColorModel.sizeFont, indexFont: self.bgColorModel.indexFont,
                                                 indexFontStyle: self.bgColorModel.indexFontStyle, textColorString: self.bgColorModel.textColorString)
            }
        case .images(let img):
            NoteManage.shared.removeCAGradientLayer(view: self.textView)
            if let img = img, let image = img.converToImage() {
                self.updateImgBg(img: image)
                self.bgColorModel = BgColorModel(color: nil, gradient: nil, image: img, textFont: self.bgColorModel.textFont,
                                                 sizeFont: self.bgColorModel.sizeFont, indexFont: self.bgColorModel.indexFont,
                                                 indexFontStyle: self.bgColorModel.indexFontStyle, textColorString: self.bgColorModel.textColorString)
            }
        }
    }
    
    private func resetBgColor() {
        NoteManage.shared.removeCAGradientLayer(view: self.textView)
        self.textView.backgroundColor = .white
        self.imgBg.isHidden = true
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
        self.imgBg.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
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
extension TextVC: CalenDarPickerViewDelegate {
    func updateReminder(calendar: CalendaModel) {
        self.reminder = calendar
    }
}
