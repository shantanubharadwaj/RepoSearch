//
//  HttpRequest.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

extension Http{
    struct Request: CustomStringConvertible {
        let id = UUID()
        var urlRequest: URLRequest
        var timeout: TimeInterval = Util.defaultHttpTimeout
        var userAgent: String = ""
        var autoRedirects: Bool = false
        var headers: [AnyHashable : Any]?
        
        var description: String {
            get {
                if let validURL = self.urlRequest.url {
                    var description = "URL: \(validURL.absoluteString)\n"
                    description += "HTTPHeaders: \(String(describing: self.urlRequest.allHTTPHeaderFields))\n"
                    description += "timeout: \(self.timeout)\n"
                    description += "autoRedirects: \(self.autoRedirects)\n"
                    return description
                }else{
                    return ""
                }
            }
        }
        
        static func requestWith(_ request: URLRequest) -> Request {
            return Request(request: request)
        }
        
        static func requestWithURL(_ url: URL) -> Request {
            return Request(url: url)
        }
        
        init(request: URLRequest) {
            urlRequest = request
        }
        
        init(url: URL) {
            urlRequest = URLRequest(url: url)
        }
        
        //hashable
        func isEqual(_ object: Any?) -> Bool {
            guard let validObject = object as? Request else {
                return false
            }
            
            return (self.id == validObject.id)
        }
        
        var hashValue: Int {
            return id.uuidString.hashValue
        }
    }
}
