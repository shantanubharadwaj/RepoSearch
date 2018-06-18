//
//  LocalStore.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

struct LocalStore {
    enum Keys {
        case nextUrl
        case currentLimit
        case resetTime
        
        func get() -> String {
            switch self {
            case .nextUrl:
                return "nextUrlKey"
            case .currentLimit:
                return "currentLimitKey"
            case .resetTime:
                return "resetTime"
            }
        }
    }
    
    // Local Store to store intermediate values for objects
    fileprivate static var localStore = Dictionary<String, Any>()
    // ****************
    static func add(_ value: Any, for key: Keys) {
        localStore.updateValue(value, forKey: key.get())
    }
    
    static func get(for key: Keys) -> Any? {
        return localStore[key.get()]
    }
    
    static func remove(for key: Keys) {
        localStore.removeValue(forKey: key.get())
    }
}
