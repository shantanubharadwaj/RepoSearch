//
//  HttpUtil.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

extension Http{
    enum Constants {
        case httpGet
        case httpPost
        
        case bracketStarttag
        case bracketEndtag
        
        // Header Fields
        case contentType
        case headerLink
        case limitRemaining
        case resetTime
        case location
        
        // Request Header Fields
        case userAgent
        case accept
        case authorization
        
        func get() -> String {
            switch self {
            case .httpGet:
                return "GET"
            case .httpPost:
                return "POST"
            case .userAgent:
                return "User-Agent"
            case .accept:
                return "Accept"
            case .authorization:
                return "Authorization"
            case .contentType:
                return "Content-Type"
            case .limitRemaining:
                return "X-RateLimit-Remaining"
            case .resetTime:
                return "X-RateLimit-Reset"
            case .headerLink:
                return "Link"
            case .location:
                return "Location"
            case .bracketStarttag:
                return "<"
            case .bracketEndtag:
                return ">"
            }
        }
        
        func getValue() -> String {
            switch self {
            case .accept:
                return "application/json"
            default:
                return ""
            }
        }
    }
    
    /*Redirection: 3xx status codes*/
    enum RedirectHttpCode {
        case multipleChoice
        case movedPermanently
        case movedTemporarily
        case seeOther
        case notModified
        case useProxy
        case temporaryRedirect
        case permanentRedirect
        
        func code() -> Int {
            switch self {
            case .multipleChoice:
                return 300
            case .movedPermanently:
                return 301
            case .movedTemporarily:
                return 302
            case .seeOther:
                return 303
            case .notModified:
                return 304
            case .useProxy:
                return 305
            case .temporaryRedirect:
                return 307
            case .permanentRedirect:
                return 308
            }
        }
    }
    
    struct Util {
        static var defaultHttpTimeout: TimeInterval {
            return 25.0
        }
    }
}
