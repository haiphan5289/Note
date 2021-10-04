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
    }
    
    private let configStyle: ConfigStyle = ConfigStyle.loadXib()
    private let configText: ConfigText = ConfigText.loadXib()
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
        self.view.addSubview(self.configStyle)
        self.setupConfigStyleWithoutKeyboard()
        self.configStyle.delegate = self
        
        self.configText.delegate = self
        self.view.addSubview(self.configText)
        self.configText.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(Constant.heightViewText + ConstantCommon.shared.getHeightSafeArea(type: .bottom))
        }
        self.configText.isHidden = true
    }
    
    private func configRX() {
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
            (h > 0) ? self.setupConfigStyleWHaveKeyboard(height: h) : self.setupConfigStyleWithoutKeyboard()
            self.configStyle.updateStatusKeyboard(status: (h > 0) ? .open : .hide)
        }
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
extension BaseNavigationHeader: ConfigStyleDelegate {
    func showConfigStyleText() {
        self.configText.isHidden = false
    }
    
    func updateStatusKeyboard(status: ConfigStyle.StatusKeyboard) {
        self.eventStatusKeyboard.onNext(status)
    }
}
extension BaseNavigationHeader: ConfigTextDelegate {
    func dismiss() {
        self.configText.isHidden = true
        self.configStyle.updateStatusKeyboard(status: .open)
    }
    
    func save() {
        self.configText.isHidden = true
        self.configStyle.updateStatusKeyboard(status: .open)
    }
    
    func showConfigText() {
        
    }
    
    func pickColor() {
        
    }
    
    
}
