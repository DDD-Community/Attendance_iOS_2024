//
//  CoreMember.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import Foundation
import Service

import ComposableArchitecture
import KeychainAccess
import FirebaseAuth


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
        var isLoading: Bool = false
        var qrcodeImage: String = "qrcode"
        var eventImage: String = "flag.square"
        var user: User? =  nil
        
        @Presents var destination: Destination.State?
        
        
    }
    
    public enum Action  {
        case selectPartButton(selectPart: SelectPart)
        case appearSelectPart(selectPart: SelectPart)
        case swipeNext
        case swipePrevious
        case fetchMember
        case upDateFetchMember(selectPart: SelectPart)
        case fetchDataResponse(Result<[Attendance], Error>)
        case destination(PresentationAction<Destination.Action>)
        case presntQrcode
        case upDateDataQRCode
        case updateAttendanceModel([Attendance])
        case fetchModel([Attendance])
        case fetchCurrentUser
        case fetchUserDataResponse(Result<User, Error>)
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case qrcode(QrCode)
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
                
            case .destination(_):
                return .none
                
            case .presntQrcode:
                
                try? Keychain().set(state.user?.uid ?? "" , key: "userID")
                return .none
                
            case .upDateDataQRCode:
                state.destination = .qrcode(.init(userID: state.attendaceModel.first?.id ?? ""))
                return .none
                
            case let .updateAttendanceModel(newValue):
                state.attendaceModel = [ ]
                state.attendaceModel = newValue
                // Add any additional logic if needed
                return .none
                
            case let .fetchModel(newValue):
                state.attendaceModel = [ ]
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
                
            case let .upDateFetchMember(selectPart: selectPart):
                return .run { send in
                    do {
                        let fetchedData = try await fireStoreUseCase.fetchFireStoreData(from: "members", as: Attendance.self)
                        let filteredData = fetchedData.filter { $0.roleType != .all && (selectPart == .all || $0.roleType == selectPart) }
                        await send(.updateAttendanceModel(fetchedData))
                        await send(.fetchDataResponse(.success(filteredData)))
                    } catch {
                        await send(.fetchDataResponse(.failure(error)))
                    }
                }
                
            case let .fetchDataResponse(.success(fetchedData)):
                state.isLoading = false
                state.attendaceModel = fetchedData
                return .none
                
            case let .fetchDataResponse(.failure(error)):
                Log.error("Error fetching data", error)
                state.isLoading = true
                return .none
                
            case .fetchCurrentUser:
                return .run { send in
                    do {
                        guard  let fetchedUserData = try await fireStoreUseCase.getCurrentUser() else { return  }
                        await send(.fetchUserDataResponse(.success(fetchedUserData)))
                    } catch {
                        await send(.fetchUserDataResponse(.failure(error)))
                    }
                }
                
            case let .fetchUserDataResponse(.success(fetchUser)):
                state.user = fetchUser
                Log.error("fetching data", fetchUser.uid)
                return .none
            
            case let .fetchUserDataResponse(.failure(error)):
                Log.error("Error fetching User", error)
                state.user = nil
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .onChange(of: \.attendaceModel) { oldValue, newValue in
            Reduce { state, action in
                state.attendaceModel = newValue
                
                return .none
            }
        }
    }
}
