//
//  Date+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 14/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

extension Date {
    init?(ISO8601String: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: ISO8601String) else {return nil}
        self = date
    }
    
    init?(age: Int) {
        guard let date = Calendar.current.date(byAdding: .month, value: -age, to: Date()) else {return nil}
        self = date
    }
    
    func convert(into dateStyle: DateFormatter.Style) -> String {
        if let dateIsRecentString = Date().checkIfDateIsRecent(date: self) {
            return dateIsRecentString
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = dateStyle
            dateFormatter.locale = Locale.current
            return dateFormatter.string(from: self)
        }
    }
    
    func convert(into dateStyle: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .none
        dateFormatter.dateFormat = dateStyle
        return dateFormatter.string(from: self)
    }
    
    func checkIfDateIsRecent(date: Date) -> String?  {
        let components = NSCalendar.current.dateComponents([Calendar.Component.day], from: date, to: self)
        if let days = components.day, days < 30 {
            if days == 1 {
                return "1 dag siden"
            } else {
                return "\(days) dage siden"
            }
        } else {
            return nil
        }
    }
}
