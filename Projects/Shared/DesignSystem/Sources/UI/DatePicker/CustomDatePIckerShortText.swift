//
//  CustomDatePIckerShortText.swift
//  DesignSystem
//
//  Created by 서원지 on 7/20/24.
//

import SwiftUI

import Utill

public struct CustomDatePickerShortText: View {
    @Binding private var selectedDate: Date
    var isTimeDate: Bool = false
    
    @State private var isDateSelected: Bool = false
    
    public init(
        selectedDate: Binding<Date>,
        isTimeDate: Bool = false
    ) {
        self._selectedDate = selectedDate
        self.isTimeDate = isTimeDate
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            if isTimeDate {
                Text(selectedDate.formattedTimes(date: selectedDate))
                    .pretendardFont(family: .Regular, size: 17)
                    .foregroundStyle(isDateSelected ? Color.basicWhite : Color.gray600)
            } else {
                Text(Date.formattedDateTimeText(date: selectedDate))
                    .pretendardFont(family: .Regular, size: 17)
                    .foregroundStyle(isDateSelected ? Color.basicWhite : Color.gray600)
            }
        }
        .padding(.horizontal, 11)
        .overlay {
            if isTimeDate {
                DatePicker(selection: Binding(get: {
                    selectedDate
                }, set: { newDate in
                    selectedDate = newDate
                    isDateSelected = true
                }), displayedComponents: [.hourAndMinute]) { }
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .colorMultiply(.clear)
//                .datePickerStyle(.automatic)
                .labelsHidden()
            } else {
                DatePicker(selection: Binding(get: {
                    selectedDate
                }, set: { newDate in
                    selectedDate = newDate
                    isDateSelected = true
                }), displayedComponents: [.date]) { }
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .colorMultiply(.clear)
                .datePickerStyle(.automatic)
                .labelsHidden()
            }
        }
    }
}
