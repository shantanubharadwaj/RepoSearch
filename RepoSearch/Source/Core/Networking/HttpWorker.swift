//
//  HttpWorker.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

struct Http {
    typealias SuccessHandler = (Http.Request, Http.Response) -> ()
    typealias ErrorHandler = (Http.Request, Http.Error) -> ()
}

/// HttpWorker protocol to perform http reuqest
protocol HttpWorker {
    /// Sends a HTTP request and returns the success or failure through success and error handlers. You can send as many SMCHttpRequest with the same worker as possible.
    func send(_ request: Http.Request, success: @escaping Http.SuccessHandler, error: @escaping Http.ErrorHandler)
    
    /// Cancels an alreay in progress Http.Request if there's one. If there's a request
    /// in progress then cancels it and returns true, if there's no request in progress then also it returns true, in all other cases this function returns false.
    @discardableResult
    func cancel(_ request: Http.Request) -> Bool
    
    /// Cancels all the Http.Request that are in progress. Returns true if there's
    /// atleast one request to be cancelled and was successfully canceled, false otherwise
    @discardableResult
    func cancelAll() -> Bool
}
