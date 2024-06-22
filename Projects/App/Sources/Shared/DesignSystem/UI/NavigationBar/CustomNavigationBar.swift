//
//  CustomNavigationBar.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/22/24.
//

import SwiftUI

public struct CustomNavigationBar: View {
    var backAction: () -> Void = { }
    var addAction: () -> Void = { }
    
    public init(
        backAction: @escaping () -> Void,
        addAction: @escaping () -> Void
    ) {
        self.backAction = backAction
        self.addAction = addAction
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 18)
                .foregroundColor(.white)
                .onTapGesture {
                    backAction()
                }
            
            Spacer()
            
            HStack {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 18)
                    .foregroundColor(.white)
                    .onTapGesture {
                        addAction()
                    }
            }
            
        }
        .padding(.horizontal, 20)
    }
}
