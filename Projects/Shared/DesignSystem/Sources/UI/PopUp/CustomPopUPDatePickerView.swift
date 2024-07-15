//
//  CustomPopUPDatePickerView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/19/24.
//

import Foundation
import SwiftUI

public struct CustomPopUPDatePickerView: View {
    @Binding var selectDate: Date
    
    public init(selectDate:  Binding<Date>) {
        self._selectDate = selectDate
    }
    
    
    public var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.basicBlackDimmed.opacity(0.8))
                .frame(width: UIScreen.screenWidth - 20 , height: UIScreen.screenHeight * 0.25)
                .overlay {
                    Spacer()
                        .frame(height: 12)
                    
                    datePickerView()
                    
                    Spacer()
                        .frame(height: 12)
                }
        }
    }
}


extension CustomPopUPDatePickerView {
    
    @ViewBuilder
    fileprivate func datePickerView() -> some View {
        VStack {
            DatePicker(selection: $selectDate, in: ...Date(), displayedComponents: [.date]) {
                
            }
            .foregroundColor(Color.basicBlackDimmed)
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .datePickerStyle(.wheel)
            .labelsHidden()
            
            Spacer()
            
        }
    }
    
}
