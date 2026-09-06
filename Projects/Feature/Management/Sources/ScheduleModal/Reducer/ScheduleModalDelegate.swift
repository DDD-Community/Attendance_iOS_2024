//
//  ScheduleModalDelegate.swift
//  Management
//
//  Created by DDD on 2026-09-03.
//

import ScheduleDomainInterface

import ComposableArchitecture

@CasePathable
public enum ScheduleModalDelegate: Equatable, Sendable {
  case selectScheduleCompleted(selectedSchedule: Schedule)
}
