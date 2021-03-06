//
//  BaseNavigationHeader.swift
//  Note
//
//  Created by haiphan on 02/10/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BaseNavigationHeader: UIViewController {
    
    struct Constant {
        static let heightViewStyle: CGFloat = 50
        static let heightViewText: CGFloat = 150
        static let heightViewListFont: CGFloat = 400
        static let heightTextView: CGFloat = 300
        static let widthTextView: CGFloat = 0.9
        static let topContraintTextView: CGFloat = 10
        static let botContraintTextView: CGFloat = 10
        static let tagImage: Int = 99
    }
    
    enum StatusFont {
        case cancel, update(String, CGFloat), done(String, CGFloat, Int, Int)
    }
    
    enum StatusBgColor {
        case cancel, done(BackgroundColor.BgColorTypes)
    }
    
    enum TextColorStatus {
        case cancel, done
    }
    
    var noteModel: NoteModel?
    
    private let configStyleView: ConfigStyle = ConfigStyle.loadXib()
    private let configTextView: ConfigText = ConfigText.loadXib()
    private let listFontView: ListFont = ListFont.loadXib()
    private let bgView: BackgroundColor = BackgroundColor.loadXib()
    
    let eventUpdateFontStyleView: BehaviorRelay<UIFont> = BehaviorRelay.init(value: ConstantApp.shared.fontDefault)
    let eventShowListFontView: PublishSubject<Bool> = PublishSubject.init()
    let eventFont: PublishSubject<StatusFont> = PublishSubject.init()
    let eventHeightKeyboard: PublishSubject<CGFloat> = PublishSubject.init()
    let navigationItemView: NavigationItemView = NavigationItemView.loadXib()
    let eventUpdateBgColor: PublishSubject<BackgroundColor.BgColorTypes> = PublishSubject.init()
    let eventPickBgColor: PublishSubject<StatusBgColor> = PublishSubject.init()
    let eventSaveTextColor: PublishSubject<TextColorStatus> = PublishSubject.init()
    
    @Published var eventPickColor: UIColor
    @VariableReplay var textColor: UIColor = Asset.textColorApp.color
    @VariableReplay var noteModelBase: NoteModel?
    
    let eventStatusKeyboard: PublishSubject<ConfigStyle.StatusKeyboard> = PublishSubject.init()
    var vContainer: UIView!
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            // MARK: Navigation Bar Customisation
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                        NSAttributedString.Key.font: UIFont.myMediumSystemFont(ofSize: 18)]
        self.navigationController?.navigationBar.barTintColor = Asset.navigationBar.color
        self.navigationController?.isNavigationBarHidden = false
        
        vContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationController?.navigationBar.frame.height ?? 50))
           
        vContainer.backgroundColor = UIColor.clear
        vContainer.clipsToBounds = true
        vContainer.addSubview(self.navigationItemView)
        self.navigationItemView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        navigationController?.navigationBar.addSubview(vContainer)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vContainer.removeFromSuperview()
    }
    
    private func configUI() {
        self.view.addSubview(self.configStyleView)
        self.configStyleView.setupConfigStyleWithoutKeyboard()
        self.configStyleView.delegate = self
        
        self.configTextView.delegate = self
        self.configTextView.addViewToParent(view: self.view)
        self.configTextView.hideView()
        
        self.listFontView.delegate = self
        self.listFontView.addViewToParent(view: self.view)
        self.listFontView.isHidden = true
        
        if let note = self.noteModel {
            self.navigationItemView.setupValuePin(isPin: note.isPin ?? false)
        }
    }
    
    private func configRX() {
        
        self.eventHeightKeyboard.asObservable().bind { [weak self] h in
            guard let wSelf = self else { return }
            if h > 0 {
                wSelf.configStyleView.updateStatusKeyboard(status: .open)
                wSelf.configTextView.hideView()
                wSelf.listFontView.hide()
                wSelf.eventFont.onNext(.cancel)
                wSelf.bgView.hideView()
            }
        }.disposed(by: disposeBag)
        
        self.eventUpdateFontStyleView.asObservable().bind { [weak self] font in
            guard let wSelf = self else { return }
            wSelf.configTextView.showTextFont(font: font)
        }.disposed(by: disposeBag)
        
        let show = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        
        Observable.merge(show, hide).bind(onNext: weakify({ (keyboard, wSelf) in
            wSelf.runAnimate(by: keyboard)
        })).disposed(by: disposeBag)
    }
    
    private func runAnimate(by keyboarInfor: KeyboardInfo?) {
        guard let i = keyboarInfor else {
            return
        }
        let h = i.height
        let d = i.duration
        
        UIView.animate(withDuration: d) {
            (h > 0) ? self.configStyleView.setupConfigStyleWHaveKeyboard(height: h) : self.configStyleView.setupConfigStyleWithoutKeyboard()
            self.eventHeightKeyboard.onNext(h)
        }
    }
    
    func hidePickCOlor() {
        self.configStyleView.bts[ConfigStyle.ActionConfig.color.rawValue].isHidden = true
    }
}
extension BaseNavigationHeader: ConfigStyleDelegate {
    func showBackgroundColor() {
        self.bgView.delegate = self
        self.bgView.addViewToParent(view: self.view)
        self.eventStatusKeyboard.onNext(.hide)
        self.eventShowListFontView.onNext(false)
        self.bgView.showView()
    }
    
    func showConfigStyleText() {
        self.configTextView.showView()
        self.configTextView.updateColorWellSelector(color: self.textColor)
    }
    
    func updateStatusKeyboard(status: ConfigStyle.StatusKeyboard) {
        self.eventStatusKeyboard.onNext(status)
    }
}
extension BaseNavigationHeader: ConfigTextDelegate {
    func pickColor(color: UIColor) {
        self.$eventPickColor.onNext(color)
    }
    
    func dismiss() {
        self.configTextView.hideView()
        self.configStyleView.updateStatusKeyboard(status: .open, updateStatus: true)
        self.eventSaveTextColor.onNext(.cancel)
    }
    
    func save() {
        self.configTextView.hideView()
        self.configStyleView.updateStatusKeyboard(status: .open, updateStatus: true)
        self.eventSaveTextColor.onNext(.done)
    }
    
    func showConfigText() {
        self.listFontView.showView()
        self.listFontView.scrollWhenOpen()
        self.eventShowListFontView.onNext(self.listFontView.isHidden)
        if let note = self.noteModelBase, let bg = note.bgColorModel, let indexFont = bg.indexFont, let indexStyle = bg.indexFontStyle {
            self.listFontView.scrollToIndex(index: indexFont, indexStyle: indexStyle)
        }
    }
    
    func pickColor() {
        
    }
    
    
}
extension BaseNavigationHeader: ListFontDelegate {
    func updateFontStyle(fontName: String, size: CGFloat) {
        self.eventFont.onNext(.update(fontName, size))
    }
    
    func done(fontName: String, indexFont: Int, size: CGFloat, indexSize: Int) {
        self.listFontView.hide()
        self.eventFont.onNext(.done(fontName, size, indexFont, indexSize))
        self.eventShowListFontView.onNext(self.listFontView.isHidden)
    }
    
    func dismissListFont() {
        self.listFontView.hide()
        self.eventFont.onNext(.cancel)
        self.eventShowListFontView.onNext(self.listFontView.isHidden)
    }
    
    func search() {
        let vc = ListFontVC.createVC()
        vc.selectFontIndex = self.listFontView.getSelectIndexFont()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
extension BaseNavigationHeader: ListFontVCDelegae {
    func selectFont(index: Int) {
        self.listFontView.scrollToIndex(index: index)
    }
}
extension BaseNavigationHeader: BackgroundColorDelegate {
    func doneBgColor(bgColorType: BackgroundColor.BgColorTypes) {
        self.eventShowListFontView.onNext(true)
        self.eventPickBgColor.onNext(.done(bgColorType))
    }
    
    func updateBgColor(bgColorType: BackgroundColor.BgColorTypes) {
        self.eventUpdateBgColor.onNext(bgColorType)
    }
    
    func dismissBgColor() {
        self.eventShowListFontView.onNext(true)
        self.eventPickBgColor.onNext(.cancel)
    }
    
}
