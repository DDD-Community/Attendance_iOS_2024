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

import Utill
import Model
import DesignSystem
import LogMacro

@Reducer
public struct CoreMember {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        
        var headerTitle: String = "출석 현황"
        var selectPart: SelectPart? = .all
        var attendaceMemberModel : [MemberDTO] = []
        var attendanceCheckInModel: [AttendanceDTO] = []
        var disableSelectButton: Bool = false
        var isActiveBoldText: Bool = false
        var isLoading: Bool = false
        var qrcodeImage: ImageAsset = .qrCode
        var eventImage: ImageAsset = .eventGenerate
        var mangerProfilemage: ImageAsset = .mangeMentProfile
        
        var user: User? =  nil
        var errorMessage: String?
        var attenaceTypeImageName: String = "checkmark"
        var attenaceTypeColor: Color? = nil
        var attenaceNameColor: Color? = nil
        var attenaceGenerationColor: Color?  = nil
        var attenaceRoleTypeColor: Color? = nil
        var attenaceBackGroudColor: Color? = nil
        var attendanceCount: Int = 0
        
        var notEventText: String = "인원이 없습니다."
        
        @Presents var destination: Destination.State?
        var selectDate: Date = Date.now
        var selectDatePicker: Bool = false
        var isDateSelected: Bool = false
        //        @Presents var alert: AlertState<Action.Alert>?
        
        public init(
            //            attendaceModel : [Attendance] = [],
            //            combinedAttendances: [Attendance] = []
        ) {
            //            self.attendaceModel = attendaceModel
            //            self.combinedAttendances = combinedAttendances
        }
        
    }
    
    public enum Action : BindableAction, FeatureAction, Equatable {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case selectDate(date: Date)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
        
    }
    
    //MARK: - View action
    @CasePathable
    public enum View: Equatable {
        case swipeNext
        case swipePrevious
        case selectPartButton(selectPart: SelectPart)
        case appearSelectPart(selectPart: SelectPart)
        case updateAttendanceCountWithData(attendances: [AttendanceDTO])
        
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case fetchMember
        case fetchAttenDance
        case fetchAttendanceHistory(String)
        case fetchCurrentUser
        
        case fetchAttendanceHistoryResponse(Result<[Attendance], CustomError>)
        
        case observeAttendance
        case fetchUserDataResponse(Result<User, CustomError>)
        case fetchMemberDataResponse(Result<[MemberDTO], CustomError>)
        case fetchAttendanceDataResponse(Result<[AttendanceDTO], CustomError>)
        
        case upDateFetchAttandanceMember(selectPart: SelectPart)
        
    }
    
    //MARK: - 앱내에서 사용하는 액선
    public enum InnerAction: Equatable {
        
    }
    
    //MARK: - 네비게이션 연결 액션
    public enum NavigationAction: Equatable {
        case presentQrcode
        case presentSchedule
        case presentMangerProfile
        
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case qrcode(QrCode)
        case scheduleEvent(ScheduleEvent)
        
    }
    
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                
            case .selectDate(let date):
                if state.selectDate == date {
//                    state.selectDatePicker.toggle()
                    state.isDateSelected.toggle()
                } else {
                    state.selectDate = date
//                    state.selectDatePicker.toggle()
                    state.isDateSelected.toggle()
                }
                return .run { send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(
                            from: .attendance,
                            as: Attendance.self,
                            shouldSave: false
                        )
                    }
                    
                    switch fetchedDataResult {
                        
                    case let .success(fetchedData):
                        await send(.async(.fetchMember))
                        let filteredData = fetchedData
                            .filter { $0.updatedAt.formattedDateToString() == date.formattedDateToString()  && (($0.id?.isEmpty) != nil) }
                            .map { $0.toAttendanceDTO() }
                        #logDebug("날짜 홗인", fetchedData.map { $0.updatedAt.formattedDateToString() }, date.formattedDateToString(), filteredData)
                        await send(.async(.fetchAttendanceDataResponse(.success(filteredData))))
                        await send(.view(.updateAttendanceCountWithData(attendances: filteredData)))
                        
                    case let .failure(error):
                        await send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
                    }
                }
                
            case .destination(_):
                return .none
                
                //            case .alert(.presented(.presentAlert)):
                //                return .none
                
                
                //MARK: - ViewAction
            case .view(let viewAction):
                switch viewAction {
                case .swipeNext:
                    guard let selectPart = state.selectPart else { return .none }
                    if let currentIndex = SelectPart.allCases.firstIndex(of: selectPart),
                       currentIndex < SelectPart.allCases.count - 1 {
                        let nextPart = SelectPart.allCases[currentIndex + 1]
                        if nextPart.isDescEqualToAttendanceListDesc {
                            state.selectPart = nextPart
                        }
                    }
                    return .none
                    
                case .swipePrevious:
                    guard let selectPart = state.selectPart else { return .none }
                    if let currentIndex = SelectPart.allCases.firstIndex(of: selectPart),
                       currentIndex > 0 {
                        state.selectPart = SelectPart.allCases[currentIndex - 1]
                    }
                    return .none
                    
                case let .appearSelectPart(selectPart):
                    state.selectPart = selectPart
                    return .none
                    
                case let .selectPartButton(selectPart):
                    state.selectPart = selectPart
                    state.isActiveBoldText = (selectPart != nil)  // selectPart가 선택된 경우 bold text 활성화
                    return .none
                    
                case let .updateAttendanceCountWithData(attendances):
                    let today = Calendar.current.startOfDay(for: Date())  // 현재 날짜
                    let selectedDay = Calendar.current.startOfDay(for: state.selectDate)  // 선택된 날짜의 시작 시각 (년/월/일 기준으로)

                    // 모든 attendance의 updatedAt과 선택된 날짜를 출력
                    attendances.forEach { attendance in
                        #logDebug("Attendance ID: \(attendance.id ?? "N/A") - updatedAt: \(attendance.updatedAt), selectedDay: \(selectedDay)")
                    }

                    // 선택된 날짜와 attendance의 updatedAt의 **년/월/일**이 같은 경우만 처리
                    let filteredAttendances = attendances.filter { attendance in
                        let isSameDay = Calendar.current.isDate(attendance.updatedAt, inSameDayAs: selectedDay)  // 년/월/일 기준 비교
                        #logDebug("Attendance ID: \(attendance.id ?? "N/A") - isSameDay: \(isSameDay) - Status: \(attendance.status ?? .absent)")
                        return isSameDay && (attendance.status == .present || attendance.status == .late)
                    }

                    // 필터링된 출석 상태를 기준으로 카운트 계산
                    let presentCount = filteredAttendances.count
                    state.attendanceCount = max(0, presentCount)  // 최소 0 이상으로 설정

                    // 디버그 로그 추가
                    #logDebug("Filtered Attendance Count: \(presentCount)")
                    
                    return .none
                }
                //MARK: - AsyncAction
            case .async(let AsyncAction):
                switch AsyncAction {
                case .fetchMember:
                    return .run {  send in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .member,
                                as: Attendance.self,
                                shouldSave: false
                            )
                        }
                        
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            let filterData = fetchedData
                                .filter { $0.memberType == .member || !$0.name.isEmpty }
                                .map { $0.toMemberDTO() }
                            await send(.async(.fetchMemberDataResponse(.success(filterData))))
                            
                        case let .failure(error):
                            await send(.async(.fetchMemberDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                    //MARK: - 실시간으로 데이터 가져오기 출석현황
                case .fetchAttenDance:
                    return .run {  send in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .attendance,
                                as: Attendance.self,
                                shouldSave: false
                            )
                        }
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            await send(.async(.fetchMember))
                            let filterData = fetchedData
                                .map { $0.toAttendanceDTO() }
                            await send(.async(.fetchAttendanceDataResponse(.success(filterData))))
                            await send(.view(.updateAttendanceCountWithData(attendances: filterData)))
                            
                            
                        case let .failure(error):
                            await send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case let .fetchAttendanceHistory(uid):
                    return .run { send in
                        for await result in try await fireStoreUseCase.fetchAttendanceHistory(uid, from: .attendance) {
                            await send(.async(.fetchAttendanceHistoryResponse(result)))
                        }
                    }
                    
                case let .fetchAttendanceHistoryResponse(result):
                    return .run { send in
                        switch result {
                        case .success(let attendances):
                            let filteredData = attendances
                                .filter { (($0.id?.isEmpty) != nil) && $0.memberType == .member && !$0.name.isEmpty }
                                .map { $0.toAttendanceDTO() }
                            await send(.async(.fetchAttendanceDataResponse(.success(filteredData))))
                            await send(.view(.updateAttendanceCountWithData(attendances: filteredData)))
                            
                        case .failure(let error):
                            await send(.async(.fetchAttendanceDataResponse(.failure(CustomError.encodingError(error.localizedDescription)))))
                        }
                    }
                    
                case .fetchCurrentUser:
                    return .run {  send in
                        let fetchUserResult = await Result {
                            try await fireStoreUseCase.getCurrentUser()
                        }
                        
                        switch fetchUserResult {
                        case let .success(user):
                            if let user = user {
                                await send(.async(.fetchUserDataResponse(.success(user))))
                            }
                        case let .failure(error):
                            await send(.async(.fetchUserDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case .observeAttendance:
                    return .run { send in
                        for await result in try await fireStoreUseCase.observeFireBaseChanges(
                            from: .attendance,
                            as: Attendance.self
                        ) {
//                            // Map each Attendance model to AttendanceDTO and send the result
//                            let dtoResult = result.map { $0.toAttendanceDTO() }
//                            await send(.async(.fetchAttendanceDataResponse(dtoResult)))
                        }
                    }
                    
                case let .upDateFetchAttandanceMember(selectPart: selectPart):
                    let selectData = state.selectDate
                    return .run {  send in
                        let fetchedAttandanceResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .attendance,
                                as: Attendance.self,
                                shouldSave: false
                            )
                        }
                        
                        switch fetchedAttandanceResult {
                        case let .success(fetchedData):
                            if selectPart == .all {
                                await send(.async(.fetchMember))
                            } else {
                                let filteredData = fetchedData
                                    .filter {$0.roleType == selectPart  && $0.updatedAt.formattedDateToString() == selectData.formattedDateToString() }
                                    .map { $0.toAttendanceDTO() }
                                await send(.async(.fetchAttendanceDataResponse(.success(filteredData))))
                            }
                            
                        case let .failure(error):
                            await
                            send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
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
                    
                case let .fetchAttendanceDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedAttendanceData):
                        let filteredData = fetchedAttendanceData.filter {
                            ($0.id.isEmpty == false) && $0.memberType == .member && !$0.name.isEmpty
                        }
                        
                        let selectedDate = state.selectDate
                        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
                        let today = Calendar.current.startOfDay(for: Date())
                        
                        let updatedData = filteredData.map { attendance -> AttendanceDTO in
                            if !Calendar.current.isDate(attendance.updatedAt, inSameDayAs: selectedDay) {
                                var modifiedAttendance = attendance
                                modifiedAttendance.status = .notAttendance
                                return modifiedAttendance
                            }
                            return attendance
                        }
                        
                        if Calendar.current.isDate(selectedDate, inSameDayAs: today) {
                            state.attendanceCheckInModel = updatedData
                        } else {
                            state.attendanceCheckInModel = updatedData
                        }
                        
                    case let .failure(error):
                        #logError("출석  정보 데이터 에러", error.localizedDescription)
                        state.isLoading = true
                    }
                    return .none
                    
                    
                case let .fetchMemberDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        state.isLoading = false
                        let filteredData = fetchedData.filter { $0.memberType == .member && !$0.name.isEmpty }
                        state.attendaceMemberModel = filteredData
                        
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
                case .presentQrcode:
                    state.destination = .qrcode(.init(userID: state.user?.uid ?? ""))
                    try? Keychain().set(state.user?.uid ?? "" , key: "userID")
                    return .none
                    
                case .presentSchedule:
                    state.destination = .scheduleEvent(.init(generation: state.attendaceMemberModel.first?.generation ?? .zero))
                    return .run {  send in
                        await send(.async(.fetchMember))
                    }
                    
                case .presentMangerProfile:
                    return .none
                    
                }
                //            case .alert(.dismiss):
                //                state.alert = nil
                //                return .none
            }
        }
        
        .ifLet(\.$destination, action: \.destination)
        //        .ifLet(\.$alert, action: \.alert)
//        .onChange(of: \.attendaceMemberModel) { oldValue, newValue in
//            Reduce { state, action in
//                state.attendaceMemberModel = newValue
//                return .none
//            }
//        }        
        .onChange(of: \.attendanceCheckInModel) { oldValue, newValue in
            Reduce { state, action in
                state.attendanceCheckInModel = newValue
                return .none
            }
        }
        .onChange(of: \.attendanceCount) { oldValue, newValue in
            Reduce { state, action in
                state.attendanceCount = newValue
                return .none
            }
        }
    }
}


extension CoreMember.Action {
    public static func == (lhs: CoreMember.Action, rhs: CoreMember.Action) -> Bool {
        switch (lhs, rhs) {
        case (.binding(let lhsAction), .binding(let rhsAction)):
            return lhsAction == rhsAction
        case (.selectDate(let lhsDate), .selectDate(let rhsDate)):
            return lhsDate == rhsDate
        case (.view(let lhsViewAction), .view(let rhsViewAction)):
            return lhsViewAction == rhsViewAction
        case (.async(let lhsAsyncAction), .async(let rhsAsyncAction)):
            return lhsAsyncAction == rhsAsyncAction
        case (.inner(let lhsInnerAction), .inner(let rhsInnerAction)):
            return lhsInnerAction == rhsInnerAction
        case (.navigation(let lhsNavigationAction), .navigation(let rhsNavigationAction)):
            return lhsNavigationAction == rhsNavigationAction
        default:
            return false
        }
    }
}
