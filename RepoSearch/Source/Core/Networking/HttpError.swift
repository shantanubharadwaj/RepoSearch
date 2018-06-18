//
//  HttpError.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

extension Http{
    enum ErrorCodes: Int {
        case invalidResponse
        case cancelled
    }
    
    struct Error: CustomStringConvertible {
        let errorCode: Int
        let errorReason: String?
        init(code: Int, errorDescription: String? = nil) {
            errorCode = code
            errorReason = errorDescription
        }
        
        var description: String{
            return "HttpError :> [code: \(errorCode), reason: \(errorReason ?? "")]"
        }
    }
}
