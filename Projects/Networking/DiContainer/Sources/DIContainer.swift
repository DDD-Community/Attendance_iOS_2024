//
//  DIContainer.swift
//  DiContainer
//
//  Created by 서원지 on 6/8/24.
//

import Foundation
import Service
import LogMacro

public final class DependencyContainer {
    private var registry = [String: Any]()
    private var releaseHandlers = [String: () -> Void]()

    public init() { }

    @discardableResult
    public func register<T>(_ type: T.Type, build: @escaping () -> T) async -> () -> Void {
        let key = String(describing: type)
        registry[key] = build
        Log.debug("Registered", key)
        
        let releaseHandler = { [weak self] in
            self?.registry[key] = nil
            self?.releaseHandlers[key] = nil
            Log.debug("Released", key)
        }
        
        releaseHandlers[key] = releaseHandler
        return releaseHandler
    }

    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: T.self)
        if let factory = registry[key] as? () -> T {
            
            let result = factory()
            if let releaseHandler = releaseHandlers[key] {
                releaseHandler()
            }
            return result
        } else {
            fatalError("No registered dependency found for \(key)")
        }
    }
}

public extension DependencyContainer {
    static let live = DependencyContainer()
}
