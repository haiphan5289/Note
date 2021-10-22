
//
//  
//  PhotoVC.swift
//  Note
//
//  Created by haiphan on 22/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class PhotoVC: BaseNavigationHeader {
    
    // Add here outlets
    var noteModel: NoteModel?
    var imagePhotoLibrary: UIImage?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    // Add here your view model
    private var viewModel: PhotoVM = PhotoVM()
    
    private var previousFont: UIFont?
    private var bgColorModel: BgColorModel = BgColorModel.empty
    
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
extension PhotoVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        textView.clipsToBounds = true
        textView.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        textView.centerVertically()
        textView.becomeFirstResponder()
        previousFont = textView.font
        self.eventUpdateFontStyleView.accept(textView.font ?? ConstantApp.shared.fontDefault)
        
        self.textColor = textView.textColor ?? Asset.colorApp.color
        
        if let note = self.noteModel {
            self.updateValueNote(note: note)
        } else {
            self.bgColorModel = BgColorModel.empty
        }
        
        self.imageView.contentMode = .scaleToFill
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
       
        if let img = self.imagePhotoLibrary {
            self.imageView.image = img
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
                wSelf.navigationController?.popViewController(animated: true, {
                    let noteModel: NoteModel
                    let notePhoto = NotePhotoModel(imgData: wSelf.imageView.image?.pngData(), text: wSelf.textView.text)
                    if let note = wSelf.noteModel {
                        noteModel = NoteModel(noteType: .photo, text: nil, id: note.id, bgColorModel: nil,
                                              updateDate: Date.convertDateToLocalTime(), noteCheckList: nil, noteDrawModel: nil, notePhotoModel: notePhoto)
                    } else {
                        noteModel = NoteModel(noteType: .photo, text: nil, id: Date.convertDateToLocalTime(), bgColorModel: nil,
                                              updateDate: Date.convertDateToLocalTime(), noteCheckList: nil, noteDrawModel: nil, notePhotoModel: notePhoto)
                    }
                    RealmManager.shared.updateOrInsertConfig(model: noteModel)
                })
        
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
    }
    
    private func updateValueNote(note: NoteModel) {
        
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
    
    private func textViewHideKeyboard() {
        self.textView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.height.equalTo(Constant.heightTextView)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.textView)
        }
    }
    
    private func textViewShowKeyboard(height: CGFloat) {
        self.textView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Constant.topContraintTextView)
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(height + BaseNavigationHeader.Constant.heightViewStyle + Constant.botContraintTextView)
        }
        self.imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.textView)
        }
    }
    
    private func textViewShowListFont() {
        self.textView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Constant.topContraintTextView)
            make.width.equalToSuperview().multipliedBy(Constant.widthTextView)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(BaseNavigationHeader.Constant.heightViewListFont + Constant.botContraintTextView)
        }
        self.imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.textView)
        }
    }
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
