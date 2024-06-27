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
import SwiftUI


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
        var editEventImage: String = "pencil"
        var logOutImage: String = "rectangle.portrait.and.arrow.right"
        var user: User? =  nil
        var errorMessage: String?
        
        @Presents var destination: Destination.State?
        var selectDate: Date = Date.now
        var selectDatePicker: Bool = false
//        @Presents var alert: AlertState<Action.Alert>?
        
    }
    
    public enum Action : BindableAction {
        case binding(BindingAction<State>)
        case selectPartButton(selectPart: SelectPart)
        case appearSelectPart(selectPart: SelectPart)
        case swipeNext
        case swipePrevious
        case fetchMember
        case upDateFetchMember(selectPart: SelectPart)
        case fetchDataResponse(Result<[Attendance], CustomError>)
        case destination(PresentationAction<Destination.Action>)
        case presentQrcode
        case presentEditEvent
        case presentSNS
        case upDateDataQRCode
        case updateAttendanceModel([Attendance])
        case fetchCurrentUser
        case fetchUserDataResponse(Result<User, CustomError>)
        case observeAttendance
        case presntEventModal
        case closePresntEventModal
        case presntEventEditViewToModal
        case tapLogOut
        
        case selectDate(date: Date)
//        case alert(PresentationAction<Alert>)
        
//            @CasePathable
//           public enum Alert {
//                case presentAlert
//            }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case qrcode(QrCode)
        case makeEvent(MakeEvent)
        
    }
    
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                
            case let .selectPartButton(selectPart: selectPart):
                if state.selectPart == selectPart {
                    state.selectPart = nil
                    state.isActiveBoldText = false
                } else {
                    state.selectPart = selectPart
                    state.isActiveBoldText = true
                }
                return .none
                
            case .selectDate(let date):
                if  state.selectDate == date {
                    state.selectDatePicker.toggle()
                } else {
                    state.selectDate = date
                    state.selectDatePicker.toggle()
                }
                
                return .run { @MainActor send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(
                            from: .member,
                            as: Attendance.self,
                            shouldSave: false)
                    }
                    
                    switch fetchedDataResult {
                        
                    case let .success(fetchedData):
                        let filteredData = fetchedData.filter { $0.updatedAt.formattedDateToString() == date.formattedDateToString() }
                        Log.debug("날짜 홗인", fetchedData.map { $0.updatedAt.formattedDateToString() }, date.formattedDateToString(), filteredData)
                         send(.updateAttendanceModel(fetchedData))
                         send(.fetchDataResponse(.success(filteredData)))
                        
                    case let .failure(error):
                        send(.fetchDataResponse(.failure(CustomError.map(error))))
                    }
                }
                
            case let .appearSelectPart(selectPart: selectPart):
                state.selectPart = selectPart
                return .none
                
            case .destination(_):
                return .none
                
            case .presentQrcode:
                state.destination = .qrcode(.init(userID: state.user?.uid ?? ""))
                try? Keychain().set(state.user?.uid ?? "" , key: "userID")
                return .none
                
                
            case .presentEditEvent:
                return .none
                
            case .presentSNS:
                return .none
                
//            case .alert(.presented(.presentAlert)):
//                return .none
                
            case .upDateDataQRCode:
                state.destination = .qrcode(.init(userID: state.user?.uid ?? "" , startTime: state.selectDate))
                return .none
                
            case let .updateAttendanceModel(newValue):
                state.attendaceModel = [ ]
                state.attendaceModel = newValue
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
                        try await fireStoreUseCase.fetchFireStoreData(
                            from: .member,
                            as: Attendance.self,
                            shouldSave: false)
                    }
                    
                    switch fetchedDataResult {
                        
                    case let .success(fetchedData):
                        let filterData = fetchedData.filter { $0.memberType == .member }
                         send(.fetchDataResponse(.success(filterData)))
                        
                    case let .failure(error):
                         send(.fetchDataResponse(.failure(CustomError.map(error))))
                    }
                    
                }
                
            case .tapLogOut:
                return .run { @MainActor send  in
                    let fetchUserResult = await Result {
                        try await fireStoreUseCase.getUserLogOut()
                    }
                    
                    switch fetchUserResult {
                        
                    case let .success(fetchUserResult):
                        guard let fetchUserResult = fetchUserResult else {return}
                         send(.fetchUserDataResponse(.success(fetchUserResult)))
                        
                    case let .failure(error):
                        send(.fetchUserDataResponse(.failure(CustomError.map(error))))
                    }
                }
                
            case let .upDateFetchMember(selectPart: selectPart):
                return .run { @MainActor send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(
                            from: .member,
                            as: Attendance.self,
                            shouldSave: false
                        )
                    }
                    
                    switch fetchedDataResult {
                        
                    case let .success(fetchedData):
                        let filteredData = fetchedData.filter { $0.roleType != .all && (selectPart == .all || $0.roleType == selectPart) && $0.memberType == .member }
                         send(.updateAttendanceModel(fetchedData))
                         send(.fetchDataResponse(.success(filteredData)))
                        
                    case let .failure(error):
                        send(.fetchDataResponse(.failure(CustomError.map(error))))
                    }
                }
                
            case .observeAttendance:
                return .run { send in
                    for await result in try await fireStoreUseCase.observeFireBaseChanges(
                        from:  .member,
                        as: Attendance.self
                    ) {
                        await send(.fetchDataResponse(result))
                    }
                }
                
            case let .fetchDataResponse(fetchedData):
                switch fetchedData {
                case let .success(fetchedData):
                    state.isLoading = false
                    state.attendaceModel = fetchedData.filter { $0.memberType == .member}
                case let .failure(error):
                    Log.error("Error fetching data", error)
                    state.isLoading = true
                }
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
                
            case .presntEventModal:
                state.destination = .makeEvent(MakeEvent.State())
                return .none
                
            case .closePresntEventModal:
                state.destination = nil
                return .none
              
            case .presntEventEditViewToModal:
                state.destination = .makeEvent(MakeEvent.State())
                return .none
                
//            case .alert(.dismiss):
//                state.alert = nil
//                return .none
            }
        }
        
        .ifLet(\.$destination, action: \.destination)
//        .ifLet(\.$alert, action: \.alert)
        .onChange(of: \.attendaceModel) { oldValue, newValue in
            Reduce { state, action in
                state.attendaceModel = newValue
                return .none
            }
        }
    }
}
