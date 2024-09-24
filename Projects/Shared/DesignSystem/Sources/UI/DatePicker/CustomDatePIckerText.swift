//
//  CustomDatePIckerText.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import SwiftUI

import Utill

public struct CustomDatePIckerText: View {
    @Binding private var selectedDate: Date

    public init(
        selectedDate: Binding<Date>
    ) {
        self._selectedDate = selectedDate
    }

    public var body: some View {
        HStack {
            Spacer()

            Text(Date.formattedDateTimeText(date: selectedDate))
                .pretendardFont(family: .Regular, size: 16)
                .foregroundColor(Color.basicWhite)

            Spacer()
                .frame(width: 8)

            VStack {
                Image(asset: .arrow_down)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 8)
                    .foregroundColor(Color.gray600)
            }

            Spacer()
        }
        .overlay {
            VStack {
                DatePicker(
                    selection: $selectedDate,
                    displayedComponents: [.date]) { }
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .datePickerStyle(.automatic)
                .labelsHidden()
                .colorMultiply(.clear)
                .cornerRadius(8)
                .transition(.opacity)
            }
        }
    }
}



