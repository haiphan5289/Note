//
//  DateExtension.swift
//  Dayshee
//
//  Created by paxcreation on 11/2/20.
//  Copyright © 2020 ThanhPham. All rights reserved.
//

import UIKit

extension Date {
    private static let formatDateDefault = DateFormatter()
    func string(from format: String = "dd/MM/yyyy") -> String {
        Date.formatDateDefault.locale = Locale(identifier: "en_US_POSIX")
        Date.formatDateDefault.dateFormat = format
        let result = Date.formatDateDefault.string(from: self)
        return result
    }
    
    static func convertDateToLocalTime() -> Date {
            let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: Date()))
            return Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: Date())!
    }
    
    func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)

        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        components.second = sec

        return cal.date(from: components)
    }
}
