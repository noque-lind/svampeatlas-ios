//
//  Date+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 14/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

extension Date {
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
          return calendar.dateComponents(Set(components), from: self)
      }

      func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
          return calendar.component(component, from: self)
      }
    
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
    
    func convertIntoISO8601String() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: self)
    }
    
    func convert(into dateStyle: DateFormatter.Style, ignoreRecentFormatting: Bool = false, ignoreTime: Bool = false) -> String {
        if ignoreRecentFormatting != true, let dateIsRecentString = Date().checkIfDateIsRecent(ignoreTime: ignoreTime, date: self) {
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
    
    func removeTimeStamp() -> Date {
           guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
               return Date()
           }
           return date
       }

    func checkIfDateIsRecent(ignoreTime: Bool, date: Date) -> String? {
        let components = NSCalendar.current.dateComponents([Calendar.Component.day, Calendar.Component.hour], from: date, to: self)
        if let days = components.day, days < 30 {
            if days == 0 {
                if let hours = components.hour, ignoreTime == false {
                    if hours == 0 {
                        return NSLocalizedString("dateFormatting_rightNow", comment: "")
                    } else {
                        return String.localizedStringWithFormat(NSLocalizedString("dateFormatting_hoursSince", comment: ""), hours)
                    }
                } else {
                    return NSLocalizedString("dateFormatting_today", comment: "")
                }
            } else if days == 1 {
                return NSLocalizedString("dateFormatting_1dayHasPassed", comment: "")
            } else {
                return String.localizedStringWithFormat(NSLocalizedString("dateFormatting_daysPassed", comment: ""), days)
            }
        } else {
            return nil
        }
    }
}
