//
//  DDDEvent.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

struct DDDEvent: Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var startTime: Date
    var endTime: Date
    var location: String
    var latitude: Double
    var longitude: Double
    
    /// 기수
    var generation: Int
}
