//
//  Extension+String.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation
extension String {
    static func combine(userID: String, eventID: String, creationTime: Date) -> String {
        let creationTimeString = creationTime.formattedString()
        return "\(userID)+\(eventID)+\(creationTimeString)"
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.date(from: dateString)
    }
    
    func stringToTimeAndDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        return dateFormatter.date(from: dateString)
    }

}
