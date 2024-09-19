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

@Reducer
public struct CoreMember {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        
        var headerTitle: String = "출석 현황"
        var selectPart: SelectPart? = nil
        var selectParts: [SelectPart] =  []
        var attendaceMemberModel : [Attendance] = []
        var attendanceCheckInModel: [Attendance] = []
        var disableSelectButton: Bool = false
        var isActiveBoldText: Bool = false
        var isLoading: Bool = false
        var qrcodeImage: ImageAsset = .qrCode
        var eventImage: ImageAsset = .eventGenerate
        var mangerProfilemage: String = "person"
        
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
    
    public enum Action : BindableAction, ViewAction, FeatureAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case selectDate(date: Date)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
        
    }
    
    //MARK: - View action
    public enum View {
        case swipeNext
        case swipePrevious
        case selectPartButton(selectPart: SelectPart)
        case appearSelectPart(selectPart: SelectPart)
        case updateAttendanceCountWithData(attendances: [Attendance])
        
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
        case fetchMemberDataResponse(Result<[Attendance], CustomError>)
        case fetchAttendanceDataResponse(Result<[Attendance], CustomError>)
        
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
                    state.selectDatePicker.toggle()
                    state.isDateSelected.toggle()
                } else {
                    state.selectDate = date
                    state.selectDatePicker.toggle()
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
                        let filteredData = fetchedData.filter { $0.updatedAt.formattedDateToString() == date.formattedDateToString()  && (($0.id?.isEmpty) != nil) }
                        Log.debug("날짜 홗인", fetchedData.map { $0.updatedAt.formattedDateToString() }, date.formattedDateToString(), filteredData)
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
                    state.selectPart = state.selectPart == selectPart ? nil : selectPart
                    state.isActiveBoldText = (state.selectPart != nil)
                    return .none
                    
                case let .updateAttendanceCountWithData(attendances):
                    let today = Calendar.current.startOfDay(for: Date())
                    let selectedDate = state.isDateSelected ? state.selectDate : today
                    let selectedDay = Calendar.current.startOfDay(for: selectedDate)

                    // 선택된 날짜와 오늘 날짜 모두 updatedAt과 비교하여 출석 상태를 필터링
                    let filteredAttendances = attendances.filter { attendance in
                        // 선택된 날짜와 attendance의 updatedAt이 같은 경우만 처리
                        return Calendar.current.isDate(attendance.updatedAt, inSameDayAs: selectedDay) &&
                            (attendance.status == .present || attendance.status == .late)
                    }

                    // 필터링된 출석 상태를 기준으로 카운트 계산
                    let presentCount = filteredAttendances.count
                    state.attendanceCount = max(0, presentCount)  // 최소 0 이상으로 설정

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
                            let filterData = fetchedData.filter { $0.memberType == .member || !$0.name.isEmpty }
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
                            await send(.async(.fetchAttendanceDataResponse(.success(fetchedData))))
                            await send(.view(.updateAttendanceCountWithData(attendances: fetchedData)))
                            
                            
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
                            let filteredData = attendances.filter { (($0.id?.isEmpty) != nil) && $0.memberType == .member && !$0.name.isEmpty }
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
                            from:  .attendance,
                            as: Attendance.self
                        ) {
                            await send(.async(.fetchAttendanceDataResponse(result)))
                            
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
                                let filteredData = fetchedData.filter { $0.updatedAt.formattedDateToString() == selectData.formattedDateToString() }
                                await send(.async(.fetchAttendanceDataResponse(.success(filteredData))))
                            } else {
                                let filteredData = fetchedData.filter {$0.roleType == selectPart  && $0.updatedAt.formattedDateToString() == selectData.formattedDateToString() }
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
                        Log.error("fetching data", fetchUser.uid)
                    case let .failure(error):
                        Log.error("Error fetching User", error)
                        state.user = nil
                    }
                    return .none
                    
                case let .fetchAttendanceDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedAttendanceData):
                        let filteredData = fetchedAttendanceData.filter {
                            ($0.id?.isEmpty == false) && $0.memberType == .member && !$0.name.isEmpty
                        }
                        
                        let selectedDate = state.selectDate
                        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
                        let today = Calendar.current.startOfDay(for: Date())
                        
                        let updatedData = filteredData.map { attendance -> Attendance in
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
                        Log.error("출석  정보 데이터 에러", error.localizedDescription)
                        state.isLoading = true
                    }
                    return .none
                    
                    
                case let .fetchMemberDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        state.isLoading = false
                        let filteredData = fetchedData.filter { (($0.id?.isEmpty) != nil) && $0.memberType == .member && !$0.name.isEmpty }
                        state.attendaceMemberModel = filteredData
                        
                    case let .failure(error):
                        Log.error("Error fetching data", error)
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

