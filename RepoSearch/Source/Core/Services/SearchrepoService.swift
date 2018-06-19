//
//  SearchRepoService.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

// TODO: provide access via protocols . Services.search

/// SearchRepoService wraps the networks confguration formation and call to fetch repository data based on user search.
struct SearchRepoService {
    fileprivate let httpWorker = Http.create("SearchService")
    private let operationQueue = OperationQueue()
    private var searchLanguage: String!
    
    /// pass programming language to be searched as argument
    init?(_ language: String) {
        if let limit = LocalStore.get(for: .currentLimit) as? Int, limit <= 1 {
            if let timeLeft = LocalStore.get(for: .resetTime) as? Date, timeLeft.timeIntervalSinceNow > 0 {
                print("Not enough limit available. Please try after :\(timeLeft.timeIntervalSinceNow) seconds")
                return nil
            }
        }
        searchLanguage = language
    }
    
    init() {}
    
    /// use this api to call the nextURL (if available) which was passed in the Link header during initial call.
    func fetchNextData(_ response: (([Repository]?) -> ())?) {
        guard let nextUrl = LocalStore.get(for: .nextUrl) as? URL else {
            response?(nil)
            return
        }
        
        guard let nextrequest = URLConfiguration.generalRequest(nextUrl).getRequest(), let _ = nextrequest.urlRequest.url else {
            response?(nil)
            return
        }
        
        let networkOperation = RequestData(withURLRequest: nextrequest, andNetworkingProvider: httpWorker)
        networkOperation.qualityOfService = .userInitiated
        networkOperation.completionBlock = {
            if networkOperation.error != nil {
                print("<SearchRepoService> fetch next : Error in HTTP : [StatusCode : \(String(describing: networkOperation.response?.urlResponse.statusCode))] : <error  [\(String(describing: networkOperation.error))]>")
                response?(nil)
                return
            }
            guard let httpResponse = networkOperation.response, let data = httpResponse.data else{
                response?(nil)
                return
            }
            
            // removing local stored data, and updating local store as new values have been passed as headers
            LocalStore.remove(for: .nextUrl)
            LocalStore.remove(for: .currentLimit)
            LocalStore.remove(for: .resetTime)
            if let nextURL = networkOperation.response?.nextUrl() {
                LocalStore.add(nextURL, for: .nextUrl)
            }
            if let limitLeft = networkOperation.response?.limitRemaining() {
                LocalStore.add(limitLeft, for: .currentLimit)
            }
            if let resetTime = networkOperation.response?.resetTime() {
                LocalStore.add(resetTime, for: .resetTime)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do{
                let items = try decoder.decode(Items.self, from: data)
                if items.items.count > 0 {
                    response?(items.items)
                }else{
                    print("<SearchRepoService> fetch next : No data found")
                    response?(nil)
                }
            }catch let error {
                print("<SearchRepoService> fetch next : Error while parsing : [\(error.localizedDescription)]")
                response?(nil)
            }
        }
        operationQueue.addOperations([networkOperation], waitUntilFinished: false)
    }
    
    // Fetch api to fetch repository info. 
    func fetch(_ response: (([Repository]?) -> ())?) {
        guard let request = URLConfiguration.searchRequest(searchLanguage).getRequest(), let _ = request.urlRequest.url else {
            response?(nil)
            return
        }
        
        let networkOperation = RequestData(withURLRequest: request, andNetworkingProvider: httpWorker)
        networkOperation.qualityOfService = .userInitiated
        networkOperation.completionBlock = {
            if networkOperation.error != nil {
                print("<SearchrepoService> Error in HTTP : [StatusCode : \(String(describing: networkOperation.response?.urlResponse.statusCode))] : <error  [\(String(describing: networkOperation.error))]>")
                response?(nil)
                return
            }
            guard let httpResponse = networkOperation.response, let data = httpResponse.data else{
                response?(nil)
                return
            }

            LocalStore.remove(for: .nextUrl)
            LocalStore.remove(for: .currentLimit)
            LocalStore.remove(for: .resetTime)
            if let nextURL = networkOperation.response?.nextUrl() {
                LocalStore.add(nextURL, for: .nextUrl)
            }
            if let limitLeft = networkOperation.response?.limitRemaining() {
                LocalStore.add(limitLeft, for: .currentLimit)
            }
            if let resetTime = networkOperation.response?.resetTime() {
                LocalStore.add(resetTime, for: .resetTime)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do{
                let items = try decoder.decode(Items.self, from: data)
                if items.items.count > 0 {
                    response?(items.items)
                }else{
                    print("<SearchrepoService> Error : No data found")
                    response?(nil)
                }
            }catch let error {
                print("<SearchrepoService> Error while parsing : [\(error.localizedDescription)]")
                response?(nil)
            }
        }
        operationQueue.addOperations([networkOperation], waitUntilFinished: false)
    }
    
}
