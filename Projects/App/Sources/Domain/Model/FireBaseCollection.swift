//
//  FireBaseCollection.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/25/24.
//

import Foundation

public enum FireBaseCollection: String, CaseIterable {
    case member
    case event
    case attendance
    
    var desc: String {
        switch self {
        case .member:
            return "members"
        case .event:
            return "events"
        case .attendance:
            return "attendance"
        }
         
    }
}
