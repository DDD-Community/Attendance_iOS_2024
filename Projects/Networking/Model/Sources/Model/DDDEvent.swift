//
//  DDDEvent.swift
//  Model
//
//  Created by 서원지 on 7/20/24.
//

import Foundation

public struct DDDEvent: Codable, Hashable {
    public var id: String?
    public var name: String
    public var description: String?
    public var startTime: Date
    public var endTime: Date
    /// 기수
    public var generation: Int?
    
    public init(
        id: String? = nil,
        name: String,
        description: String? = nil,
        startTime: Date,
        endTime: Date,
        generation: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.generation = generation
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, startTime, endTime, generation
    }
    
    public func toDictionary() -> [String: Any] {
        return [
            "id": id ?? "",
            "name": name,
            "description": description ?? "",
            "startTime": startTime,
            "endTime": endTime,
            "generation": generation ?? ""
//            "latitude": latitude,
//            "longitude": longitude,
        ]
    }
}
