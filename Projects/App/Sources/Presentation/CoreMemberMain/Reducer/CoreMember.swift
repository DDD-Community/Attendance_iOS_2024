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
        var attendaceModel : [Attendance] = []
        var combinedAttendances: [Attendance] = []
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
        case updateAttendanceCount(count: Int)
        case updateAttendanceCountWithData(attendances: [Attendance])
        
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case fetchMember
        case fetchAttenDance
        case fetchAttendanceHistory(String)
        case updateAttendanceTypeModel([Attendance])
        case updateTodayAttendanceStatus([Attendance])
        case fetchAttendanceHistoryResponse(Result<[Attendance], CustomError>)
        case fetchCurrentUser
        case observeAttendance
        case updateAttendanceModel([Attendance])
        case fetchUserDataResponse(Result<User, CustomError>)
        case fetchDataResponse(Result<[Attendance], CustomError>)
        case fetchAttendanceDataResponse(Result<[Attendance], CustomError>)
        
        case upDateFetchAttandanceMember(selectPart: SelectPart)
        case updateAttenDance
        
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
                if  state.selectDate == date {
                    state.selectDatePicker.toggle()
                    state.isDateSelected.toggle()
                } else {
                    state.selectDate = date
                    state.selectDatePicker.toggle()
                    state.isDateSelected.toggle()
                }
                
                return .run { @MainActor send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(
                            from: .attendance,
                            as: Attendance.self,
                            shouldSave: false)
                    }
                    
                    switch fetchedDataResult {
                        
                    case let .success(fetchedData):
                        send(.async(.fetchMember))
                        let filteredData = fetchedData.filter { $0.updatedAt.formattedDateToString() == date.formattedDateToString()  && (($0.id?.isEmpty) != nil) }
                        Log.debug("날짜 홗인", fetchedData.map { $0.updatedAt.formattedDateToString() }, date.formattedDateToString(), filteredData)
                        send(.async(.updateTodayAttendanceStatus(filteredData)))
                        send(.view(.updateAttendanceCountWithData(attendances: filteredData)))
                        
                    case let .failure(error):
                        send(.async(.fetchDataResponse(.failure(CustomError.map(error)))))
                    }
                }
                
                
                
            case .destination(_):
                return .none
                
                //            case .alert(.presented(.presentAlert)):
                //                return .none
                
                
                //MARK: - ViewAction
            case .view(let View):
                switch View {
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
                    
                case let .appearSelectPart(selectPart: selectPart):
                    state.selectPart = selectPart
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
                    
                    
                case let .updateAttendanceCount(count: count):
                    var newAttendanceCount = 0
                    for index in state.attendaceModel.indices {
                        let attendance = state.attendaceModel[index]
                        
                        if attendance.status == .present {
                            newAttendanceCount += 1
                        } else if attendance.status == .late {
                            newAttendanceCount -= 1
                        }
                    }
                    
                    if newAttendanceCount < 0 {
                        newAttendanceCount = 0
                    }
                    
                    if newAttendanceCount > state.attendaceModel.count {
                        newAttendanceCount = state.attendaceModel.count
                    }
                    
                    state.attendanceCount = newAttendanceCount
                    newAttendanceCount = count
                    return .none
                    
                case let .updateAttendanceCountWithData(attendances):
                    var newAttendanceCount = 0
                    for attendance in attendances {
                        if attendance.status == .present || attendance.status == .late {
                            newAttendanceCount += 1
                        }
                    }
                    newAttendanceCount = max(0, min(newAttendanceCount, attendances.count))
                    state.attendanceCount = newAttendanceCount
                    return .none
                }
                //MARK: - AsyncAction
            case .async(let AsyncAction):
                switch AsyncAction {
                case .updateTodayAttendanceStatus(let attendances):
                    let selectedDate = state.selectDate
                    // Step 1: Sort attendances by updatedAt in descending order to prioritize the latest records
                    let sortedAttendances = attendances.sorted(by: { $0.updatedAt > $1.updatedAt })

                    // Step 2: Group attendances by memberId to process them by their unique identifiers
                    let fetchedDataGroupedByMemberId = Dictionary(grouping: sortedAttendances) { $0.memberId }

                    var mergedAttendancesByMemberId: [String: Attendance] = [:]

                    // Step 3: Process the grouped attendances to ensure only the latest record for each memberId is kept
                    for (memberId, attendances) in fetchedDataGroupedByMemberId {
                        guard let memberId = memberId, !memberId.isEmpty else {
                            Log.error("Attendance has empty memberId: \(attendances)")
                            continue
                        }

                        // Explicitly select the latest attendance by comparing updatedAt
                        let attendancesForSelectedDate = attendances.filter {
                            Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate)
                        }
                        
                        // Keep the latest attendance if multiple exist for the same memberId
                        if let latestAttendance = attendancesForSelectedDate.max(by: { $0.updatedAt > $1.updatedAt }) {
                            mergedAttendancesByMemberId[memberId] = latestAttendance
                        }

                    }

                    // Step 4: Update combinedAttendances with new statuses based on the latest attendance data
                    var updatedCombinedAttendances = state.combinedAttendances

                    for index in updatedCombinedAttendances.indices {
                        var existingAttendance = updatedCombinedAttendances[index]
                        if let memberId = existingAttendance.memberId,
                           let mergedAttendance = mergedAttendancesByMemberId[memberId] {
                            // Merge the latest attendance data into the existing structure
                            existingAttendance.status = mergedAttendance.status
                            existingAttendance.updatedAt = mergedAttendance.updatedAt
                            existingAttendance.id = mergedAttendance.id // Ensure the id is correctly set
                            existingAttendance.roleType = mergedAttendance.roleType
                            existingAttendance.memberType = mergedAttendance.memberType ?? existingAttendance.memberType
                            updatedCombinedAttendances[index] = existingAttendance
                        } else if Calendar.current.isDate(Date(), inSameDayAs: Date()) { // 오늘 날짜인 경우
                            existingAttendance.status = .notAttendance
                            existingAttendance.updatedAt = Date()
                            updatedCombinedAttendances[index] = existingAttendance
                        }
                    }

                    // Step 5: Ensure that combinedAttendances remain in the latest order
                    state.combinedAttendances = updatedCombinedAttendances.sorted(by: { $0.updatedAt > $1.updatedAt })
                    Log.debug("updateTodayAttendanceStatus2", state.combinedAttendances)

                    // Step 6: Update attendaceModel reflecting changes based on the latest data, only including the latest entries
                    var updatedAttendaceModel: [Attendance] = []

                    // Include only the latest data in the attendance model
                    for (_, attendance) in mergedAttendancesByMemberId {
                        // Use the latest data from mergedAttendancesByMemberId
                        let updatedAttendanceModel = Attendance(
                            id: attendance.id ?? "", // Ensure the id is correctly set
                            memberId: attendance.memberId ?? "",
                            memberType: attendance.memberType,
                            name: attendance.name,
                            roleType: attendance.roleType,
                            eventId: attendance.eventId,
                            createdAt: attendance.createdAt,
                            updatedAt: attendance.updatedAt,
                            status: attendance.status,
                            generation: attendance.generation
                        )
                        updatedAttendaceModel.append(updatedAttendanceModel)
                    }

                    // Step 7: Set the updated attendance model to state and sort by updatedAt to maintain order
                    state.attendaceModel = updatedAttendaceModel.sorted(by: { $0.updatedAt > $1.updatedAt })
                    Log.debug("updateTodayAttendanceStatus3", updatedAttendaceModel)
                    Log.debug("state.updateTodayAttendanceStatus", state.attendaceModel)
                    return .none



                    
                case .fetchMember:
                    return .run {  send  in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .member,
                                as: Attendance.self,
                                shouldSave: false)
                        }
                        
                        switch fetchedDataResult {
                            
                        case let .success(fetchedData):
                            let filterData = fetchedData.filter { $0.memberType == .member || $0.name != ""}
                            await send(.async(.fetchDataResponse(.success(filterData))))
                        case let .failure(error):
                            await send(.async(.fetchDataResponse(.failure(CustomError.map(error)))))
                        }
                        
                    }
                    
                    //MARK: - 실시간으로 데이터 가져오기 출석현황
                case .fetchAttenDance:
                    // Swift 6 and later requires the nonisolated keyword to avoid data race errors
                    // var attendanceModel = state.attendanceModel
                    return .run {  send in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .attendance,
                                as: Attendance.self,
                                shouldSave: false)
                        }
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            await send(.async(.fetchMember))
                            await send(.async(.fetchAttendanceDataResponse(.success(fetchedData))))
                            
                            let uids = Set(fetchedData.map { $0.id })
                            
                            for uid in uids {
                                await send(.async(.fetchAttendanceHistory(uid ?? "")))
                            }
                            
                        case let .failure(error):
                            await send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case let .fetchAttendanceHistory(uid):
                    return .run {  send in
                        for await result in try await fireStoreUseCase.fetchAttendanceHistory(uid, from: .attendance) {
                            await send(.async(.fetchAttendanceHistoryResponse(result)))
                        }
                    }
                    
                case let .fetchAttendanceHistoryResponse(result):
                    switch result {
                    case let .success(attendances):
                        return .send(.async(.updateAttendanceTypeModel(attendances)))
                        
                    case let .failure(error):
                        return .send(.async(.fetchAttendanceDataResponse(.failure(error))))
                    }
                    
                case let .updateAttendanceTypeModel(attendances):
                    state.combinedAttendances = attendances
                    
                    let statusDict: [String?: (AttendanceType?, String?)] = Dictionary(uniqueKeysWithValues: attendances.map { ($0.id, ($0.status, $0.id)) })
                    
                    let today = Calendar.current.startOfDay(for: Date())
                    
                    var updatedCombinedAttendances = state.combinedAttendances
                    for index in updatedCombinedAttendances.indices {
                        if let (updatedStatus, updatedId) = statusDict[updatedCombinedAttendances[index].id] {
                            let isToday = Calendar.current.isDate(updatedCombinedAttendances[index].updatedAt ?? Date.distantPast, inSameDayAs: today)
                            
                            if isToday {
                                updatedCombinedAttendances[index].status = updatedStatus
                                updatedCombinedAttendances[index].id = updatedId ?? updatedCombinedAttendances[index].id
                                updatedCombinedAttendances[index].updatedAt = Date()
                            } else {
                                updatedCombinedAttendances[index].status = .absent
                            }
                        }
                    }
                    
                    state.combinedAttendances = updatedCombinedAttendances
                    Log.debug("combinedAttendances2", state.combinedAttendances)
                    
                    let updatedAttendaceModel: [Attendance] = state.attendaceModel.map { data in
                        let updatedStatusAndId = statusDict[data.id]
                        let isToday = Calendar.current.isDate(data.updatedAt, inSameDayAs: today)
                        
                        let updatedStatus = updatedStatusAndId?.0
                        let updatedId = updatedStatusAndId?.1
                        
                        let newUpdatedAt = (updatedStatus != nil && isToday) ? Date() : data.updatedAt
                        let newStatus = isToday ? (updatedStatus ?? data.status) : .absent
                        let newId = updatedId ?? data.id
                        
                        return Attendance(
                            id: newId ?? "",
                            memberId: data.memberId ?? "",
                            memberType: data.memberType,
                            name: data.name,
                            roleType: data.roleType,
                            eventId: data.eventId,
                            createdAt: data.createdAt,
                            updatedAt: newUpdatedAt,
                            status: newStatus,
                            generation: data.generation
                        )
                    }
                    
                    state.attendaceModel = updatedAttendaceModel
                    Log.debug("updatedAttendanceModel", updatedAttendaceModel)
                    Log.debug("updatedAttendanceModel", state.attendaceModel)
                    return .none
                    
                    
                    
                    
                case .fetchCurrentUser:
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
                    
                case .observeAttendance:
                    return .run { @MainActor send in
                        for await result in try await fireStoreUseCase.observeFireBaseChanges(
                            from:  .member,
                            as: Attendance.self
                        ) {
                            send(.async(.fetchDataResponse(result)))
                            
                        }
                    }
                    
                case let .upDateFetchAttandanceMember(selectPart: selectPart):
                    return .run { @MainActor send in
                        
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .member,
                                as: Attendance.self,
                                shouldSave: false
                            )
                        }
                        let fetchedAttandanceResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .attendance,
                                as: Attendance.self,
                                shouldSave: false
                            )
                        }
                        
                        switch fetchedDataResult {
                            
                        case let .success(fetchedData):
                            let filteredData = fetchedData.filter { $0.roleType != .all && (selectPart == .all || $0.roleType.rawValue == selectPart.attendanceListDesc) && $0.memberType == .member && !$0.name.isEmpty }
                            send(.async(.fetchDataResponse(.success(filteredData))))
                            
                        case let .failure(error):
                            send(.async(.fetchDataResponse(.failure(CustomError.map(error)))))
                        }
                        
                        switch fetchedAttandanceResult {
                            
                        case let .success(fetchedData):
                            send(.async(.fetchAttendanceDataResponse(.success(fetchedData))))
                            
                        case let .failure(error):
                            send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                    
                case .updateAttenDance:
                    return .run { @MainActor send in
                        let fetchedAttandanceResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .attendance,
                                as: Attendance.self,
                                shouldSave: false
                            )
                        }
                        
                        switch fetchedAttandanceResult {
                            
                        case let .success(fetchedData):
                            send(.async(.fetchAttendanceDataResponse(.success(fetchedData))))
                            
                        case let .failure(error):
                            send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case let .updateAttendanceModel(newValue):
                    state.attendaceModel = newValue.filter { $0.id?.isEmpty != nil && $0.memberType == .member && !$0.name.isEmpty }
                    return .none
                    
                    
                    
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
                    
                case let .fetchAttendanceDataResponse(fetchedAttendanceData):
                    switch fetchedAttendanceData {
                    case let .success(fetchedData):
                        state.isLoading = false
                        
                        // Group fetched attendances by id
                        let fetchedDataGroupedById = Dictionary(grouping: fetchedData) { $0.id }
                        
                        var mergedAttendancesById: [String: Attendance] = [:]
                        
                        // Merge attendances by selecting the latest updated attendance for each id
                        for (id, attendances) in fetchedDataGroupedById {
                            if let mergedAttendance = attendances.max(by: { $0.updatedAt < $1.updatedAt }) {
                                if let id = id { // Ensure the id is not nil
                                    mergedAttendancesById[id] = mergedAttendance
                                }
                            }
                        }
                        
                        var updatedCombinedAttendances = state.combinedAttendances
                        
                        // Update combinedAttendances with statuses from merged fetched data using id
                        for index in updatedCombinedAttendances.indices {
                            var existingAttendance = updatedCombinedAttendances[index]
                            if let id = existingAttendance.id,
                               let mergedAttendance = mergedAttendancesById[id] {
                                existingAttendance.status = mergedAttendance.status
                                existingAttendance.updatedAt = mergedAttendance.updatedAt
                                existingAttendance.id = mergedAttendance.id // Ensure the ID is updated correctly
                                updatedCombinedAttendances[index] = existingAttendance
                            } else {
                                existingAttendance.status = .notAttendance
                                updatedCombinedAttendances[index] = existingAttendance
                            }
                        }
                        
                        state.combinedAttendances = updatedCombinedAttendances
                        Log.debug("combinedAttendances2", state.combinedAttendances)
                        
                        var updatedAttendaceModel: [Attendance] = []
                        for data in state.attendaceModel {
                            if let id = data.id,
                               let mergedAttendance = mergedAttendancesById[id] {
                                let updatedAttendance = Attendance(
                                    id: mergedAttendance.id ?? "",
                                    memberId: data.memberId ?? mergedAttendance.memberId ?? "",
                                    memberType: data.memberType ?? mergedAttendance.memberType,
                                    name: data.name.isEmpty ? mergedAttendance.name : data.name,
                                    roleType: data.roleType,
                                    eventId: data.eventId.isEmpty ? mergedAttendance.eventId : data.eventId,
                                    createdAt: data.createdAt,
                                    updatedAt: mergedAttendance.updatedAt,
                                    status: mergedAttendance.status ?? data.status,
                                    generation: data.generation
                                )
                                updatedAttendaceModel.append(updatedAttendance)
                            } else {
                                // Mark attendance as absent if no record found by id
                                let absentAttendance = Attendance(
                                    id: data.id ?? "",
                                    memberId: data.memberId ?? "",
                                    memberType: data.memberType,
                                    name: data.name,
                                    roleType: data.roleType,
                                    eventId: data.eventId,
                                    createdAt: data.createdAt,
                                    updatedAt: Date(), // Set to current date/time
                                    status: .notAttendance, // Mark as absent if no attendance found
                                    generation: data.generation
                                )
                                updatedAttendaceModel.append(absentAttendance)
                            }
                        }
                        
                        state.attendaceModel = updatedAttendaceModel
                        Log.debug("combinedAttendances3", state.attendaceModel)
                        
                    case let .failure(error):
                        Log.error("Error fetching data", error)
                        state.isLoading = true
                    }
                    return .none


                    
                    
                case let .fetchDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        state.isLoading = false
                        let filteredData = fetchedData.filter { (($0.id?.isEmpty) != nil) && $0.memberType == .member && !$0.name.isEmpty }
                        state.attendaceModel = filteredData
                        
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
                    state.destination = .scheduleEvent(.init(generation: state.attendaceModel.first?.generation ?? .zero))
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
        .onChange(of: \.attendaceModel) { oldValue, newValue in
            Reduce { state, action in
                state.attendaceModel = newValue
                return .none
            }
        }
        .onChange(of: \.combinedAttendances) { oldValue, newValue in
            Reduce { state, action in
                state.combinedAttendances = newValue
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

