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
            Image(asset: .arrowBack)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 20)
                .foregroundStyle(Color.gray400)
                .onTapGesture {
                    buttonAction()
                }
            
            Spacer()
            
        }
        .padding(.horizontal, 16)
    }
}
