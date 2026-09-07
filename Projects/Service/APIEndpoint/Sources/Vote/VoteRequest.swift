//
//  VoteRequest.swift
//  Service
//
//  Created by DDD on 9/1/26.
//

import Foundation

import API
import DDDNetworkInterface
import VoteDomainInterface

import Alamofire

public enum VoteRequest: DDDDataRequest, Sendable {
  case list
  case create(body: CreateVoteInput)
  case detail(voteId: Int)
  case participation(voteId: Int)
  case nonResponders(voteId: Int)
  case open(voteId: Int)
  case close(voteId: Int)
  case teamVoteResults(voteId: Int)
  case feedbackResults(voteId: Int)
  case active
  case teamVoteTemplate(voteId: Int)
  case feedbackTemplate(voteId: Int)
  case submit(voteId: Int, body: VoteSubmission)
  case myResponse(voteId: Int)

  public var path: String {
    return "api/votes" + api.description
  }

  public var method: HTTPMethod {
    switch self {
    case .list, .detail, .participation, .nonResponders,
         .teamVoteResults, .feedbackResults,
         .active, .teamVoteTemplate, .feedbackTemplate, .myResponse:
      return .get
    case .open, .close:
      return .patch
    case .create, .submit:
      return .post
    }
  }

  public var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .create(body):
      return body
    case let .submit(_, body):
      return body
    default:
      return nil
    }
  }

  private var api: VoteAPI {
    switch self {
    case .list:
      return .list
    case .create:
      return .create
    case let .detail(voteId):
      return .detail(voteId: voteId)
    case let .participation(voteId):
      return .participation(voteId: voteId)
    case let .nonResponders(voteId):
      return .nonResponders(voteId: voteId)
    case let .open(voteId):
      return .open(voteId: voteId)
    case let .close(voteId):
      return .close(voteId: voteId)
    case let .teamVoteResults(voteId):
      return .teamVoteResults(voteId: voteId)
    case let .feedbackResults(voteId):
      return .feedbackResults(voteId: voteId)
    case .active:
      return .active
    case let .teamVoteTemplate(voteId):
      return .teamVoteTemplate(voteId: voteId)
    case let .feedbackTemplate(voteId):
      return .feedbackTemplate(voteId: voteId)
    case let .submit(voteId, _):
      return .submit(voteId: voteId)
    case let .myResponse(voteId):
      return .myResponse(voteId: voteId)
    }
  }
}
