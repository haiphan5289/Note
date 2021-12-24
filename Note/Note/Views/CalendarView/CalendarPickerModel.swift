//
//  CalendarPickerModel.swift
//  Note
//
//  Created by haiphan on 24/10/2021.
//

import Foundation

struct Day: Codable {
    // 1
    let date: Date
    // 2
    let number: String
    // 3
    let isSelected: Bool
    // 4
    let isWithinDisplayedMonth: Bool
}

struct MonthMetadata {
    let numberOfDays: Int
    let firstDay: Date
    let firstDayWeekday: Int
}
