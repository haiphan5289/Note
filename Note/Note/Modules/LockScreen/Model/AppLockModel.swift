//
//  AppLockModel.swift
//  AudioRecord
//
//  Created by haiphan on 12/11/2021.
//

import Foundation

struct AppLockModel: Codable {
    let autoLockValue: MenuVC.AutoLockValue
    
    static let defaultValue = AppLockModel(autoLockValue: .never)
    
}

struct TimeAutoLock {
    let start: Date
    let end: Date
    
    func getTimeDifferent() -> TimeInterval {
        return self.end - self.start
    }
    
    static let defaultValue = TimeAutoLock(start: Date(), end: Date())
}
