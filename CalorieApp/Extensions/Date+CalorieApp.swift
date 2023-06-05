//
//  Date+CalorieApp.swift
//  CalorieApp
//
//  Created by Workspace on 21/04/22.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    var stringDateAndTime: String {
        let calendar    = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: self)
        let year        = calendar.year!
        let month       = calendar.month!
        let day         = calendar.day!
        let hour        = calendar.hour!
        let minute      = calendar.minute!
        return "\(day)-\(month)-\(year) \(hour):\(minute)"
    }
    
    var stringDate: String {
        let calendar    = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: self)
        let year        = calendar.year!
        let month       = calendar.month!
        let day         = calendar.day!
        return "\(day)-\(month)-\(year)"
    }
    
    static func -(lhs: Date, rhs: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -rhs, to: lhs)!
    }
    
    var dayInWeek : String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: date)
        return dayInWeek
    }
    
    func equalOrAfter(_ date: Date) -> Bool {
        let order = Calendar.current.compare(self, to: date, toGranularity: .day)
        
        switch order {
        case .orderedDescending:
            return true
        case .orderedAscending:
            return false
        case .orderedSame:
            return true
        }
    }
    
    func equalOrBefore(_ date: Date) -> Bool {
        let order = Calendar.current.compare(self, to: date, toGranularity: .day)
        
        switch order {
        case .orderedDescending:
            return false
        case .orderedAscending:
            return true
        case .orderedSame:
            return true
        }
    }
}

