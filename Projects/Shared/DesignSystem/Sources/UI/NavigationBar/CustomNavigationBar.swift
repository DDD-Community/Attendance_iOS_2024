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
    var image: ImageAsset
    
    public init(
        backAction: @escaping () -> Void,
        addAction: @escaping () -> Void,
        image: ImageAsset
    ) {
        self.backAction = backAction
        self.addAction = addAction
        self.image = image
    }
    
    public var body: some View {
        HStack {
            Image(asset: .arrowBack)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 20)
                .foregroundStyle(Color.gray400)
                .onTapGesture {
                    backAction()
                }
            
            Spacer()
            
            HStack {
                Image(asset: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.gray400)
                    .onTapGesture {
                        addAction()
                    }
            }
            
        }
        .padding(.horizontal, 16)
    }
}
