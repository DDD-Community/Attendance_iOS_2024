//
//  MangerProfile.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import Foundation
import ComposableArchitecture
import FirebaseAuth

import Utill
import Model
import DesignSystem
import Service

@Reducer
public struct MangerProfile {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var attendaceModel : [Attendance] = []
        var user: User? =  nil
        public init() {}
    }
    
    public enum Action: ViewAction, FeatureAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
        
    }
    
    //MARK: - View action
    public enum View {
        
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case fetchMangeProfile
        case fetchUser
        case fetchDataResponse(Result<[Attendance], CustomError>)
        case fetchUserDataResponse(Result<User, CustomError>)
    }
    
    //MARK: - 앱내에서 사용하는 액선
    public enum InnerAction: Equatable {
        
    }
    
    //MARK: - 네비게이션 연결 액션
    public enum NavigationAction: Equatable {
        
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                
                //MARK: - ViewAction
            case .view(let View):
                switch View {
                    
                }
                
                //MARK: - AsyncAction
            case .async(let AsyncAction):
                switch AsyncAction {
                    
                case let .fetchUserDataResponse(fetchUser):
                    switch fetchUser {
                    case let .success(fetchUser):
                        state.user = fetchUser
                        Log.error("fetching data", fetchUser.uid)
                    case let .failure(error):
                        Log.error("Error fetching User", error)
                        state.user = nil
                    }
                    return .none
                    
                case .fetchMangeProfile:
                    return .none
                case .fetchUser:
                    return .none
                case .fetchDataResponse(_):
                    return .none
                }
                
                //MARK: - InnerAction
            case .inner(let InnerAction):
                switch InnerAction {
                    
                }
                
                //MARK: - NavigationAction
            case .navigation(let NavigationAction):
                switch NavigationAction {
                    
                }
            }
        }
    }
}

