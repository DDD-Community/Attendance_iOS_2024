//
//  VoteDTO+.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

import VoteDomainInterface

public extension VoteListItemDTO {
  func toDomain() -> Vote {
    Vote(
      id: voteId ?? 0,
      title: title ?? "",
      status: VoteStatus(serverStatus: status ?? "DRAFT")
    )
  }
}

public extension Array where Element == VoteListItemDTO {
  func toDomain() -> [Vote] {
    map { $0.toDomain() }
  }
}

public extension VoteDetailDTO {
  func toDomain() -> Vote {
    Vote(
      id: voteId ?? 0,
      title: title ?? "",
      status: VoteStatus(serverStatus: status ?? "DRAFT")
    )
  }
}

public extension VoteParticipationDTO {
  func toDomain() -> VoteParticipation {
    VoteParticipation(
      voteId: voteId ?? 0,
      status: VoteStatus(serverStatus: status ?? "DRAFT"),
      totalMembers: totalMembers ?? 0,
      respondedMembers: respondedMembers ?? 0,
      participationRate: participationRate ?? 0
    )
  }
}

public extension NonRespondersDTO {
  func toDomain() -> [NonParticipant] {
    (members ?? []).map {
      NonParticipant(
        id: $0.memberId ?? 0,
        name: $0.name ?? "",
        teamName: $0.teamName ?? ""
      )
    }
  }
}
