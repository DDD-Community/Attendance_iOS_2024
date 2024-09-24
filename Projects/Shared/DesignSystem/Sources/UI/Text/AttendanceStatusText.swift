//
//  AttendanceStatusText.swift
//  DesignSystem
//
//  Created by 서원지 on 7/13/24.
//

import SwiftUI

import Model

public struct AttendanceStatusText: View {
    var name: String
    var generataion: String
    var roleType: String
    var nameColor: Color
    var roleTypeColor: Color
    var generationColor: Color
    var backGroudColor: Color
    
    public init(
        name: String,
        generataion: String,
        roleType: String,
        nameColor: Color,
        roleTypeColor: Color,
        generationColor: Color,
        backGroudColor: Color
    ) {
        self.name = name
        self.generataion = generataion
        self.roleType = roleType
        self.nameColor = nameColor
        self.roleTypeColor = roleTypeColor
        self.generationColor = generationColor
        self.backGroudColor = backGroudColor
    }
    
    public var body: some View {
        VStack(spacing: .zero) {
            RoundedRectangle(cornerRadius: 8)
                .fill(backGroudColor)
                .frame(height: 56)
                .overlay {
                    HStack {
                        attendanceStatusName(name: name)
                        
                        attendanceStatusGeneration(generataion: generataion)
                        
                        Spacer()
                        
                        attendanceStatusRoleType(roleType: roleType)
                    }
                    .padding(.horizontal, 20)
                }
            
            Spacer()
                .frame(height: 8)
        }
        .padding(.horizontal , 24)
        
    }
}


extension AttendanceStatusText {
    
    @ViewBuilder
    private func attendanceStatusName(
        name : String
    ) -> some View {
        Text(name)
            .pretendardFont(family: .SemiBold, size: 16)
            .foregroundStyle(nameColor)
    }
    
    
    @ViewBuilder
    private func attendanceStatusGeneration(
        generataion: String
    ) -> some View {
        Text("/ \(generataion)기")
            .pretendardFont(family: .Medium, size: 16)
            .foregroundStyle(generationColor)
    }
    
    @ViewBuilder
    private func attendanceStatusRoleType(
        roleType: String
    ) -> some View {
        Text(roleType)
            .pretendardFont(family: .Medium, size: 16)
            .foregroundStyle(roleTypeColor)
    }
}
