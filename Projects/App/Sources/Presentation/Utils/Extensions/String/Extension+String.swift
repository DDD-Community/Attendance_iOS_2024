//
//  Extension+String.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation
extension String {
    static func makeQrCodeValue(userID: String, eventID: String, startTime: Date, endTime: Date) -> String {
        let startTimeString = startTime.formattedString()
        let setEndTime = endTime.addingTimeInterval(1800)
        let endTimeString = setEndTime.formattedString()
        return "\(userID)+\(eventID)+\(startTimeString)+\(endTimeString)"
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
    
    func stringToTimeFirebaseDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분 ss초 'UTC'Z"
        return dateFormatter.date(from: dateString)
    }

}
