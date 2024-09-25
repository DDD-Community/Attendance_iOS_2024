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
        generation: Int? = .zero
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
    
    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            startTime = try container.decode(Date.self, forKey: .startTime)
            endTime = try container.decode(Date.self, forKey: .endTime)

            // Try decoding generation as Int first, then as String, and convert it to Int
            if let generationInt = try? container.decodeIfPresent(Int.self, forKey: .generation) {
                generation = generationInt
            } else if let generationString = try? container.decodeIfPresent(String.self, forKey: .generation),
                      let generationFromString = Int(generationString) {
                generation = generationFromString
            } else {
                generation = nil
            }
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


public extension DDDEvent {
    func toModel() -> DDDEventDTO {
        return DDDEventDTO(
            id: self.id ?? "",
            name: self.name,
            startTime: self.startTime ,
            endTime: self.endTime,
            generation: self.generation ?? .zero
        )
    }
}
