//
//  AppSettings.swift
//  GooDic
//
//  Created by ttvu on 6/2/20.
//  Copyright © 2020 paxcreation. All rights reserved.
//

import Foundation

enum AppSettings {
    @Storage(key: "sortModel", defaultValue: SortModel.valueDefault)
    static var sortModel: SortModel
    
    @Storage(key: "autoLock", defaultValue: MenuVC.AutoLockValue.never)
    static var autoLock: MenuVC.AutoLockValue
    
    @Storage(key: "appLockConfig", defaultValue: AppLockModel.defaultValue)
    static var appLockConfig: AppLockModel
    
}
