//
//  BackButton.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

public struct NavigationBackButton: View {
    var buttonAction: () -> Void = { }
    
    public init(
        buttonAction: @escaping () -> Void
    ) {
        self.buttonAction = buttonAction
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 18)
                .foregroundColor(.white)
                .onTapGesture {
                    buttonAction()
                }
            
            Spacer()
            
        }
        .padding(.horizontal, 20)
    }
}
