//
//  DDDEventDTO.swift
//  Model
//
//  Created by 서원지 on 9/25/24.
//

import Foundation

public struct DDDEventDTO: Codable, Equatable {
    public var id: String
    public var name: String
    public var startTime: Date
    public var endTime: Date
    public var generation:Int
    
    public init(
        id: String,
        name: String,
        startTime: Date,
        endTime: Date,
        generation: Int
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.generation = generation
    }
}


public extension DDDEventDTO {
    func toModel() -> DDDEvent {
        return DDDEvent(
            id: self.id,
            name: self.name,
            description: "",
            startTime: self.startTime,
            endTime: self.endTime,
            generation: self.generation
        )
    }
}

