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
    
    enum StatusApp {
        case bg, foreground
    }
    
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
    
    func pushLocal(day: Day, identifierNotification: String) {
        let content = UNMutableNotificationContent()
        content.title = ConstantApp.shared.titleNotificaiton
//        content.body = "Body"
        content.sound = UNNotificationSound.default

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let component = calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: day.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: identifierNotification, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func openLink(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
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
    
    private func removeNotification(note: NoteModel) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            for request in requests{
                if request.identifier == "\(note.id ?? Date.convertDateToLocalTime())" {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                }
            }
        })
    }
    
    func removeAllNote() {
        RealmManager.shared.deleteNoteAll()
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
    }
}
