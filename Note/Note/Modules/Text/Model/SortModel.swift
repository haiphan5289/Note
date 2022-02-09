//
//  ConfigApp.swift
//  Note
//
//  Created by haiphan on 09/02/2022.
//

import Foundation

struct SortModel: Codable {
    let type: DropdownActionView.Action
    let isAscending: Bool
    let viewStatus: DropdownActionView.ViewsStatus
    
    static let valueDefault = SortModel(type: .reset, isAscending: false, viewStatus: .three)
}
