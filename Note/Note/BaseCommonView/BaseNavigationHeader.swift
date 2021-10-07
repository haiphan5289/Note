//
//  BaseNavigationHeader.swift
//  Note
//
//  Created by haiphan on 02/10/2021.
//

import Foundation
import UIKit
import RxSwift

class BaseNavigationHeader: UIViewController {
    
    struct Constant {
        static let heightViewStyle: CGFloat = 50
        static let heightViewText: CGFloat = 150
        static let heightViewListFont: CGFloat = 400
    }
    
    enum StatusFont {
        case cancel, update(UIFont), done(UIFont)
    }
    
    private let configStyleView: ConfigStyle = ConfigStyle.loadXib()
    private let configTextView: ConfigText = ConfigText.loadXib()
    private let listFontView: ListFont = ListFont.loadXib()
    let eventShowListFontView: PublishSubject<Bool> = PublishSubject.init()
    let eventFont: PublishSubject<StatusFont> = PublishSubject.init()
    let eventHeightKeyboard: PublishSubject<CGFloat> = PublishSubject.init()
    let navigationItemView: NavigationItemView = NavigationItemView.loadXib()
    
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
    }
    
    private func configRX() {
        
        self.eventHeightKeyboard.asObservable().bind { [weak self] h in
            guard let wSelf = self else { return }
            if h > 0 {
                wSelf.configStyleView.updateStatusKeyboard(status: .open)
                wSelf.configTextView.hideView()
                wSelf.listFontView.hide()
                wSelf.eventFont.onNext(.cancel)
            }
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
}
extension BaseNavigationHeader: ConfigStyleDelegate {
    func showConfigStyleText() {
        self.configTextView.showView()
    }
    
    func updateStatusKeyboard(status: ConfigStyle.StatusKeyboard) {
        self.eventStatusKeyboard.onNext(status)
    }
}
extension BaseNavigationHeader: ConfigTextDelegate {
    func dismiss() {
        self.configTextView.hideView()
        self.configStyleView.updateStatusKeyboard(status: .open, updateStatus: true)
    }
    
    func save() {
        self.configTextView.hideView()
        self.configStyleView.updateStatusKeyboard(status: .open, updateStatus: true)
    }
    
    func showConfigText() {
        self.listFontView.showView()
        self.listFontView.scrollWhenOpen()
        self.eventShowListFontView.onNext(self.listFontView.isHidden)
    }
    
    func pickColor() {
        
    }
    
    
}
extension BaseNavigationHeader: ListFontDelegate {
    func updateFontStyle(font: UIFont) {
        self.eventFont.onNext(.update(font))
    }
    
    func dismissListFont() {
        self.listFontView.hide()
        self.eventFont.onNext(.cancel)
        self.eventShowListFontView.onNext(self.listFontView.isHidden)
    }
    
    func done(font: UIFont) {
        self.listFontView.hide()
        self.eventFont.onNext(.done(font))
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
