//
//  VoteTemplateDTO+.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

import VoteDomainInterface

public extension TeamVoteTemplateDTO {
  func toDomain() -> TeamVoteTemplate {
    TeamVoteTemplate(
      title: title ?? "",
      description: description ?? "",
      notice: notice ?? "",
      categories: (categories ?? []).map { $0.toDomain() }
    )
  }
}

public extension TeamVoteCategoryDTO {
  func toDomain() -> TeamVoteCategory {
    TeamVoteCategory(
      id: id ?? "",
      order: order ?? 0,
      title: title ?? "",
      maxSelectableTeams: maxSelectableTeams ?? 0,
      reasonRequired: reasonRequired ?? false,
      reasonMinLength: reasonMinLength ?? 0,
      reasonMaxLength: reasonMaxLength ?? 0,
      reasonLabel: reasonLabel ?? ""
    )
  }
}

public extension VoteTeamDTO {
  func toDomain() -> VoteTeam {
    VoteTeam(
      id: teamId ?? 0,
      name: name ?? "",
      serviceName: serviceName,
      isOwnTeam: isOwnTeam ?? false
    )
  }
}

public extension FeedbackTemplateDTO {
  func toDomain() -> FeedbackTemplate {
    FeedbackTemplate(
      title: title ?? "",
      description: description ?? "",
      questions: (questions ?? []).map { $0.toDomain() }
    )
  }
}

public extension FeedbackQuestionDTO {
  func toDomain() -> FeedbackQuestion {
    FeedbackQuestion(
      id: id ?? "",
      order: order ?? 0,
      type: VoteComponentType(rawValue: type ?? "") ?? .longText,
      title: title ?? "",
      helpText: helpText,
      required: required ?? false,
      maxSelectableOptions: maxSelectableOptions,
      maxLength: maxLength,
      options: options?.map { $0.toDomain() },
      followUp: (followUp ?? []).map { $0.toDomain() }
    )
  }
}

public extension FeedbackOptionDTO {
  func toDomain() -> FeedbackOption {
    FeedbackOption(id: id ?? "", label: label ?? "")
  }
}

public extension TeamVoteTemplateResponseDTO {
  func toDomain() -> TeamVoteTemplateInfo {
    TeamVoteTemplateInfo(
      templateVersion: templateVersion ?? 0,
      status: VoteStatus(serverStatus: status ?? "DRAFT"),
      template: template?.toDomain() ?? TeamVoteTemplate(title: "", description: "", notice: "", categories: []),
      teams: (teams ?? []).map { $0.toDomain() }
    )
  }
}

public extension FeedbackTemplateResponseDTO {
  func toDomain() -> FeedbackTemplateInfo {
    FeedbackTemplateInfo(
      templateVersion: templateVersion ?? 0,
      status: VoteStatus(serverStatus: status ?? "DRAFT"),
      template: template?.toDomain() ?? FeedbackTemplate(title: "", description: "", questions: [])
    )
  }
}

public extension ActiveVoteDTO {
  func toDomain() -> ActiveVote {
    ActiveVote(
      voteId: voteId ?? 0,
      title: title ?? "",
      alreadyResponded: alreadyResponded ?? false
    )
  }
}

public extension MyVoteResponseDTO {
  func toDomain() -> MyVoteResponse {
    MyVoteResponse(voteId: voteId ?? 0, responded: responded ?? false)
  }
}
