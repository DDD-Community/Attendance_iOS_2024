//
//  CustomDatePIckerText.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import Foundation
import SwiftUI

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


extension Date {
    func formatteDateTimeText(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}
