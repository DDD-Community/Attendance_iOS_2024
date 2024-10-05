//
//  MangerProfile.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import Foundation
import ComposableArchitecture
import FirebaseAuth
import KeychainAccess

import Utill
import Model
import DesignSystem
import Service

import LogMacro

@Reducer
public struct MangerProfile {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var attendaceModel : [MemberDTO] = []
        var user: User? =  nil
        var isLoading: Bool = false
        var mangeProfileName: String = "의 프로필"
        var mangerProfileRoleType: String = "직군"
        var mangerProfileManging: String = "담당 업무"
        var mangerProfileGeneration: String = "소속 기수"
        var logoutText: String = "로그아웃"
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
        case signOut
        case fetchDataResponse(Result<[MemberDTO], CustomError>)
        case fetchUserDataResponse(Result<User, CustomError>)
        
    }
    
    //MARK: - 앱내에서 사용하는 액선
    public enum InnerAction: Equatable {
        
    }
    
    //MARK: - 네비게이션 연결 액션
    public enum NavigationAction: Equatable {
        case tapLogOut
        case presentCreatByApp
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
                    
                case .fetchUser:
                    return .run { @MainActor send in
                        let fetchUserResult = await Result {
                            try await fireStoreUseCase.getCurrentUser()
                        }
                        
                        switch fetchUserResult {
                            
                        case let .success(fetchUserResult):
                            guard let fetchUserResult = fetchUserResult else {return}
                            send(.async(.fetchUserDataResponse(.success(fetchUserResult))))
                            
                        case let .failure(error):
                            send(.async(.fetchUserDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case .fetchMangeProfile:
                    return .run { @MainActor send  in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .member,
                                as: Attendance.self,
                                shouldSave: false)
                        }
                        
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            let filteredData = fetchedData
                                .filter { $0.memberType == .coreMember && !$0.name.isEmpty }
                                .map { $0.toMemberDTO() }
                            send(.async(.fetchDataResponse(.success(filteredData))))
                        case let .failure(error):
                            send(.async(.fetchDataResponse(.failure(CustomError.map(error)))))
                        }
                        
                    }
                    
                case .signOut:
                    return .run { @MainActor send  in
                        let fetchUserResult = await Result {
                            try await fireStoreUseCase.getUserLogOut()
                        }
                        
                        switch fetchUserResult {
                            
                        case let .success(fetchUserResult):
                            guard let fetchUserResult = fetchUserResult else {return}
                            send(.async(.fetchUserDataResponse(.success(fetchUserResult))))
                            
                        case let .failure(error):
                            send(.async(.fetchUserDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                    
                case let .fetchUserDataResponse(fetchUser):
                    switch fetchUser {
                    case let .success(fetchUser):
                        state.user = fetchUser
                        #logDebug("fetching data", fetchUser.uid)
                    case let .failure(error):
                        #logError("Error fetching User", error)
                        state.user = nil
                    }
                    return .none
                    
              
                case let .fetchDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        state.isLoading = false
                        state.attendaceModel = fetchedData
                    case let .failure(error):
                        #logError("Error fetching data", error)
                        state.isLoading = true
                    }
                    return .none
                }
                
                //MARK: - InnerAction
            case .inner(let InnerAction):
                switch InnerAction {
                    
                }
                
                //MARK: - NavigationAction
            case .navigation(let NavigationAction):
                switch NavigationAction {
                case .tapLogOut:
                    return .run { @MainActor send in
                        send(.async(.signOut))
                    }
                    
                case .presentCreatByApp:
                    return .none
                }
            }
        }
    }
}

