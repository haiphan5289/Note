//
//  background.swift
//  AudioRecord
//
//  Created by haiphan on 19/11/2021.
//

import Foundation
import RxSwift

class BackgroundLock {
    static var shared = BackgroundLock()
    private var timeAutoLock: TimeAutoLock = TimeAutoLock.defaultValue
    @VariableReplay var autoLockModel: AppLockModel = AppSettings.appLockConfig
    
    private let disposeBag = DisposeBag()

    init() {}
    
    func start() {
        
        self.$autoLockModel.asObservable().bind { app in
            AppSettings.appLockConfig = app
        }.disposed(by: disposeBag)
        
        let bg = NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).map { _ in NoteManage.StatusApp.bg }
        let foreground = NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .map { _ in NoteManage.StatusApp.foreground }
        Observable.merge(bg, foreground).skip(1).bind { [weak self] type in
            guard let wSelf = self, let vc = ConstantApp.shared.getCurrentViewController() else { return }
            switch type {
            case .bg:
                wSelf.timeAutoLock = TimeAutoLock(start: Date(), end: wSelf.timeAutoLock.end)
            case .foreground:
                wSelf.timeAutoLock = TimeAutoLock(start: wSelf.timeAutoLock.start, end: Date())
                if wSelf.autoLockModel.autoLockValue != .never && Int(wSelf.timeAutoLock.getTimeDifferent()) >= wSelf.autoLockModel.autoLockValue.valueSeconds {
                    let lock = LockScreenVC.createVC()
                    lock.modalPresentationStyle = .fullScreen
                    vc.present(lock, animated: true, completion: nil)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    func updateValueAppLock(app: AppLockModel) {
        self.autoLockModel = app
    }
}
