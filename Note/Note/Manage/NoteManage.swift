//
//  NoteManage.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//

import Foundation
import UIKit
import RxSwift

final class NoteManage {
    static var shared = NoteManage()
    
    @VariableReplay var listNote: [NoteModel] = []
    
    private let disposeBag = DisposeBag()
    private init() {}
    
    func start() {
//        self.removeAllNote()
        self.setupRX()
        
    }
    
    private func setupRX() {
        let getList = Observable.just(RealmManager.shared.getListNote())
        let updateList = NotificationCenter.default.rx.notification(NSNotification.Name(PushNotificationKeys.didUpdateNote.rawValue))
            .map { _ in RealmManager.shared.getListNote() }
        Observable.merge(getList, updateList).bind { [weak self] list in
            guard let wSelf = self else { return }
            wSelf.listNote = list.sorted(by: { $0.updateDate?.compare($1.updateDate ?? Date.convertDateToLocalTime()) == ComparisonResult.orderedDescending } )
        }.disposed(by: disposeBag)
    }
    
    func removeCAGradientLayer(view: UIView) {
        guard let subplayers = view.layer.sublayers else {
            return
        }
        
        for sublayer in subplayers where sublayer is CAGradientLayer {
            sublayer.removeFromSuperlayer()
        }
    }
    
    func deleteNote(note: NoteModel) {
        RealmManager.shared.deleteNote(note: note)
    }
    
    func removeAllNote() {
        RealmManager.shared.deleteNoteAll()
    }
}
