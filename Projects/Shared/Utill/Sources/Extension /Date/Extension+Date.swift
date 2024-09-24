//
//  Extension+Date.swift
//  Utill
//
//  Created by 서원지 on 7/20/24.
//

import Foundation
import Model

public extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func formattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
    

    func formattedTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a hh시 mm분"
        return dateFormatter.string(from: date)
    }
    
    func formattedTimes(date: Date) -> String {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    
    func formattedDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: self)
    }
    
    func formattedDateTimeToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    static func formattedDateTimeText(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    func extractDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM월"
        return dateFormatter.string(from: date)
    }
    
    func formattedFireBaseDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분 ss초 'UTC'Z"
        return dateFormatter.string(from: date)
    }
    
    func formattedFireBaseStringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a h시 mm분 ss초 'UTC'Z"
        return dateFormatter.date(from: dateString) ?? Date()
    }

    
    func dateFromTimeToString(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    func dateFromString(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    func filterEventsForToday(events: [DDDEvent]) -> [DDDEvent] {
        let currentDate = Date()
        let currentFormattedDate = currentDate.formattedDate(date: currentDate)
        
        return events.filter { event in
            let eventStartTime = event.startTime
            let eventFormattedDate = eventStartTime.formattedDate(date: eventStartTime)
            return currentFormattedDate == eventFormattedDate
        }
    }
}
