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
        selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }

    public var body: some View {
        
        // Put your own design here
        HStack {
            Spacer()
            
            Text(selectedDate.formatteDateTimeText(date: selectedDate))
                .pretendardFont(family: .Regular, size: 16)
                .foregroundColor(Color.basicWhite)
            
            Spacer()
                .frame(width: 8)
            
            Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 8)
                .foregroundColor(Color.gray600)
            
            Spacer()
            
        }
        .overlay {
            DatePicker(selection: $selectedDate,
                       in: ...Date(),
                       displayedComponents: [.date]) { }
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .colorMultiply(.clear)
            .labelsHidden()
        }

    }
}


