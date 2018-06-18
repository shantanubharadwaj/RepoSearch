//
//  HttpResponse.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

extension Http{
    struct Response {
        private let kNextTag = "rel=\"next\""
        private let kSemiColon = ";"
        private let kComma = ","
        
        fileprivate var response: HTTPURLResponse
        var urlResponse: HTTPURLResponse { get { return self.response } }
        
        fileprivate var responseData: Data?
        var data:Data? { get {return responseData } }
        var dataAsString: String? { get { return getDataAsString(String.Encoding.utf8) } }
        
        fileprivate var _finalURL: URL?
        var finalURL: URL? { get { return self._finalURL} }
        
        init(httpResponse: HTTPURLResponse, data: Data?, finalURL: URL? = nil) {
            response = httpResponse
            responseData = data
            _finalURL = finalURL
        }
        
        //MARK:- Public Functions
        func getDataAsString(_ encoding: String.Encoding) -> String? {
            guard let validData = self.responseData else {
                return nil
            }
            return NSString(data: validData, encoding: encoding.rawValue) as String?
        }
        
        func locationHeader() -> URL? {
            print("Response:locationHeader() :: Header fields \(self.urlResponse.allHeaderFields)")
            guard let redirectURL = self.urlResponse.allHeaderFields[Http.Constants.location.get()] as? String else {
                return nil
            }
            guard let locationHeaderURL = URL(string: redirectURL) else{
                return nil
            }
            print("Response:locationHeader() :: returning URL \(redirectURL)")
            return locationHeaderURL
        }
        
        func nextUrl() -> URL? {
            guard let linkInfo = self.urlResponse.allHeaderFields[Constants.headerLink.get()] as? String else {
                return nil
            }
            
            let elements = linkInfo.components(separatedBy: kComma)
            var validUrl: URL?
            elements.forEach { (element) in
                if let _ = element.range(of: kNextTag, options: .caseInsensitive) {
                    if let nextUrl = element.components(separatedBy: kSemiColon).first?.removeInvalidCharacters.removingPercentEncoding,
                        let url = URL(string: nextUrl){
                        print("Response: nextUrl() :: \(url.absoluteString)")
                        validUrl = url
                    }
                }
            }
            return validUrl
        }
        
        func limitRemaining() -> Int? {
            guard let limitLeft = self.urlResponse.allHeaderFields[Constants.limitRemaining.get()] as? Int else {
                return nil
            }
            return limitLeft
        }
        
        func resetTime() -> Date? {
            guard let resetTime = self.urlResponse.allHeaderFields[Constants.resetTime.get()] as? Int else {
                return nil
            }
            return Date(timeIntervalSince1970: TimeInterval(resetTime))
        }
    }
}
