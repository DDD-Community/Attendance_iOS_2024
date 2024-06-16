//
//  MakeEvent.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct MakeEvent {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var makeEventTitle: String = "이벤트 생성"
        var isSelectDropDownMenu: Bool = false
        var selectMakeEventReason: String = "이번주 세션 이벤트를 선택 해주세요!"
        var selectPart: SelectPart? = nil
        
       
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tapCloseDropDown
        case selectAttendaceMemberButton(selectPart: SelectPart)
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding(_):
                return .none
                
            case .tapCloseDropDown:
                state.isSelectDropDownMenu = false
                return .none
                
            case let .selectAttendaceMemberButton(selectPart: selectPart):
                if state.selectPart == selectPart {
                    state.selectPart = nil
                } else {
                    state.selectPart = selectPart
                }
                
                return .none
            }
        }
    }
}

