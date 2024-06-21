//
//  SNSLoginViewReducer.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct SNSLoginViewReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}

