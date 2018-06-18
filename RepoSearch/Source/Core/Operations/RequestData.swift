//
//  RequestData.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

class RequestData: ASOperation {
    private let urlRequest: Http.Request
    private let provider: HttpWorker
    
    var response: Http.Response?
    var error: Http.Error?
    
    init(withURLRequest urlRequest: Http.Request, andNetworkingProvider provider: HttpWorker) {
        self.urlRequest = urlRequest
        self.provider = provider
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        provider.send(urlRequest, success: { [weak self] (request, response) in
            self?.response = response
            self?.executing(false)
            self?.finish(true)
        }) { [weak self] (request, error) in
            self?.error = error
            self?.executing(false)
            self?.finish(true)
        }
    }
}
