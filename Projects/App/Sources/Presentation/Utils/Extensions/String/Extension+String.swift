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
}
