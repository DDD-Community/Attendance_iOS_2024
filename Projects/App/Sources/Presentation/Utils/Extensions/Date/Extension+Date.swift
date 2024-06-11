//
//  Extension+Date.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}
