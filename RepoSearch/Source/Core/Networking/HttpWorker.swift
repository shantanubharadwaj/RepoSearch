//
//  HttpWorker.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

struct Http {
    typealias SuccessHandler = (Http.Request, Http.Response) -> ()
    typealias ErrorHandler = (Http.Request, Http.Error) -> ()
}

protocol HttpWorker {
    func send(_ request: Http.Request, success: @escaping Http.SuccessHandler, error: @escaping Http.ErrorHandler)
    @discardableResult
    func cancel(_ request: Http.Request) -> Bool
    
    @discardableResult
    func cancelAll() -> Bool
}
