//
//  Date+Extension.swift
//  Shareds
//
//  Created by 고병학 on 6/10/24.
//

import Foundation

public extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self.startOfDay)!.addingTimeInterval(-1)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
}
