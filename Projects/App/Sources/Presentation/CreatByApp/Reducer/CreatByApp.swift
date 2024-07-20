//
//  CreatByApp.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/21/24.
//

import Foundation
import ComposableArchitecture

import Utill
import SwiftUI

@Reducer
public struct CreatByApp {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        var creatByAppTitle: String = "만든 사람들"
        var creatByAppDesigner: String = "박미선"
        var creatByAppiOS: String = "고병학, 서원지"
        var creatByAppAndroid: String = "심은석"
    }
    
    public enum Action: ViewAction, FeatureAction {
        case view(View)
        case inner(InnerAction)
        case navigation(NavigationAction)
        case async(AsyncAction)
    }
    
    public enum View {
        
    }
    
    public enum InnerAction: Equatable {
        
    }
    
    public enum AsyncAction: Equatable {
        
    }
    
    public enum NavigationAction : Equatable {
        
    }
    
    
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let View):
                switch View {
                    
                }
                
            case .async(let AsyncAction):
                switch AsyncAction {
                    
                }
                
            case .inner(let InnerAction):
                switch InnerAction {
                    
                }
                
            case .navigation(let NavigationAction):
                switch NavigationAction {
                    
                }
            }
        }
    }
}

