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
        case fetchDataResponse(Result<[Attendance], CustomError>)
        case destination(PresentationAction<Destination.Action>)
        case presntQrcode
        case upDateDataQRCode
        case updateAttendanceModel([Attendance])
        case fetchCurrentUser
        case fetchUserDataResponse(Result<User, CustomError>)
        case observeAttendance
        case presntEventModal
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case qrcode(QrCode)
        case makeEvent(MakeEvent)
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
                return .run { @MainActor send  in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(from: "members", as: Attendance.self)
                    }
                    
                    switch fetchedDataResult {
                        
                    case let .success(fetchedData):
                         send(.fetchDataResponse(.success(fetchedData)))
                        
                    case let .failure(error):
                         send(.fetchDataResponse(.failure(CustomError.map(error))))
                    }
                    
                }
                
            case let .upDateFetchMember(selectPart: selectPart):
                return .run { @MainActor send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(from: "members", as: Attendance.self)
                    }
                    
                    switch fetchedDataResult {
                        
                    case let .success(fetchedData):
                        let filteredData = fetchedData.filter { $0.roleType != .all && (selectPart == .all || $0.roleType == selectPart) }
                         send(.updateAttendanceModel(fetchedData))
                         send(.fetchDataResponse(.success(filteredData)))
                        
                    case let .failure(error):
                        send(.fetchDataResponse(.failure(CustomError.map(error))))
                    }
                }
                
            case .observeAttendance:
                return .run { send in
                    for await result in try await fireStoreUseCase.observeAttendanceChanges(from: "members") {
                        await send(.fetchDataResponse(result))
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
                return .run { @MainActor send in
                    let fetchUserResult = await Result {
                        try await fireStoreUseCase.getCurrentUser()
                    }
                    
                    switch fetchUserResult {
                        
                    case let .success(fetchUserResult):
                        guard let fetchUserResult = fetchUserResult else {return}
                         send(.fetchUserDataResponse(.success(fetchUserResult)))
                        
                    case let .failure(error):
                        send(.fetchDataResponse(.failure(CustomError.map(error))))
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
                
            case .presntEventModal:
                state.destination = .makeEvent(MakeEvent.State())
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
