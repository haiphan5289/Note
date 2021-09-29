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
    
    func convertDateToLocalTime() -> Date {
            let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
            return Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self)!
    }
}
