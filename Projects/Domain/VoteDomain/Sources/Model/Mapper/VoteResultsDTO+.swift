//
//  VoteResultsDTO+.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

import VoteDomainInterface

public extension TeamVoteResultsDTO {
  func toDomain() -> TeamVoteResults {
    TeamVoteResults(
      voteId: voteId ?? 0,
      title: title ?? "",
      status: VoteStatus(serverStatus: status ?? "DRAFT"),
      totalResponses: totalResponses ?? 0,
      categories: (categories ?? []).map { $0.toDomain() }
    )
  }
}

public extension TeamVoteResultCategoryDTO {
  func toDomain() -> TeamVoteResultCategory {
    TeamVoteResultCategory(
      id: categoryId ?? "",
      title: title ?? "",
      order: order ?? 0,
      teams: (teams ?? []).map { $0.toDomain() },
      reasons: reasons ?? []
    )
  }
}

public extension TeamVoteRankDTO {
  func toDomain() -> TeamVoteRank {
    TeamVoteRank(
      rank: rank ?? 0,
      teamId: teamId ?? 0,
      name: name ?? "",
      serviceName: serviceName,
      voteCount: voteCount ?? 0
    )
  }
}

public extension FeedbackResultsDTO {
  func toDomain() -> FeedbackResults {
    FeedbackResults(
      voteId: voteId ?? 0,
      totalResponses: totalResponses ?? 0,
      questions: (questions ?? []).map { $0.toDomain() }
    )
  }
}

public extension FeedbackResultQuestionDTO {
  func toDomain() -> FeedbackResultQuestion {
    FeedbackResultQuestion(
      id: questionId ?? "",
      title: title ?? "",
      type: VoteComponentType(rawValue: type ?? "") ?? .longText,
      order: order ?? 0,
      options: options?.map { $0.toDomain() },
      trueCount: trueCount,
      falseCount: falseCount,
      textAnswers: textAnswers
    )
  }
}

public extension FeedbackResultOptionDTO {
  func toDomain() -> FeedbackResultOption {
    FeedbackResultOption(optionId: optionId ?? "", label: label ?? "", count: count ?? 0)
  }
}
