//
//  CoreMember.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import Foundation
import ComposableArchitecture
import Service

@Reducer
 public struct CoreMember {
     public init() {}
     
    @ObservableState
     public struct State: Equatable {
        public init() {}
        var headerTitle: String = "출석 현황"
        var selectPart: SelectPart? = nil
        var attendaceModel : [Attendance] = []
        var disableSelectButton: Bool = false
        var isActiveBoldText: Bool = false
        
    }
    
     public enum Action {
        case selectPartButton(selectPart: SelectPart)
        case appearSelectPart(selectPart: SelectPart)
        case swipeNext
        case swipePrevious
        case fetchMember
        case fetchDataResponse(Result<[Attendance], Error>)
         
        
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
     public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectPartButton(selectPart: selectPart):
                if state.selectPart == selectPart {
                    state.selectPart = nil
                    state.isActiveBoldText = false
                } else {
                    state.selectPart = selectPart
                    state.isActiveBoldText = true
                }
                state.disableSelectButton = state.selectPart != nil
                
                return .none
                
            case let .appearSelectPart(selectPart: selectPart):
                state.selectPart = selectPart
                return .none
                
            case .swipeNext:
                guard let selectPart = state.selectPart else { return .none }
                if let currentIndex = SelectPart.allCases.firstIndex(of: selectPart),
                   currentIndex < SelectPart.allCases.count - 1 {
                    state.selectPart = SelectPart.allCases[currentIndex + 1]
                }
                return .none
                
            case .swipePrevious:
                guard let selectPart = state.selectPart else { return .none }
                if let currentIndex = SelectPart.allCases.firstIndex(of: selectPart),
                   currentIndex > 0 {
                    state.selectPart = SelectPart.allCases[currentIndex - 1]
                }
                return .none
                
                
            case .fetchMember:
                return .run { send in
                    do {
                        let fetchedData = try await fireStoreUseCase.fetchFireStoreData(from: "members", as: Attendance.self)
                        await send(.fetchDataResponse(.success(fetchedData)))
                    } catch {
                        await send(.fetchDataResponse(.failure(error)))
                    }
                }
                
            case let .fetchDataResponse(.success(fetchedData)):
                state.attendaceModel = fetchedData
                return .none
                
            case let .fetchDataResponse(.failure(error)):
                Log.error("Error fetching data", error)
                return .none
            }
        }
    }
}

