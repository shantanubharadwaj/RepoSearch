//
//  RepoDetailsInfoFetcher.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 6/19/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

/// RepoDetailsInfoFetcher wraps the networks confguration formation and call to fetch details of the repository whose cell was chosen.
struct RepoDetailsInfoFetcher {
    fileprivate let httpWorker = Http.create("RepoDetailsSearchService")
    private let operationQueue = OperationQueue()
    private var issueSearchURL: URL!
    private var contributorsURL: URL!
    
    /// pass issue url to fetch all the issues corresponding to the repository
    init(issueURL: URL) {
        self.issueSearchURL = issueURL
    }
    
    /// pass contributors url to fetch all the contributors corresponding to the repository
    init(contributors: URL) {
        self.contributorsURL = contributors
    }
    
    // fetch issue list with the given http request url provided in the initial repo request
    func fetchIssueList(_ response: (([Issues]?) -> ())?) {
        guard let issueSearchURL = issueSearchURL,
            let issuerequest = URLConfiguration.issuesSearch(issueSearchURL).getRequest(),
            let _ = issuerequest.urlRequest.url else {
                response?(nil)
                return
        }
        let issueNetworkOperation = RequestData(withURLRequest: issuerequest, andNetworkingProvider: httpWorker)
        issueNetworkOperation.qualityOfService = .userInitiated
        issueNetworkOperation.completionBlock = {
            if issueNetworkOperation.error != nil {
                print("<IssueSearchService> Error in HTTP : [StatusCode : \(String(describing: issueNetworkOperation.response?.urlResponse.statusCode))] : <error  [\(String(describing: issueNetworkOperation.error))]>")
                response?(nil)
                return
            }
            guard let httpResponse = issueNetworkOperation.response, let data = httpResponse.data else{
                response?(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do{
                let issues = try decoder.decode([Issues].self, from: data)
                if issues.count > 0 {
                    response?(issues)
                }else{
                    print("<IssueSearchService> Error : No data found")
                    response?(nil)
                }
            }catch let error {
                print("<IssueSearchService> Error while parsing : [\(error.localizedDescription)]")
                response?(nil)
            }
        }
        operationQueue.addOperations([issueNetworkOperation], waitUntilFinished: false)
    }
    
    // fetch contributors list with the given http request url provided in the initial repo request
    func fetchContributorList(_ response: (([Contributors]?) -> ())?) {
        guard let contributorURL = contributorsURL,
            let contributorsrequest = URLConfiguration.contributorSearch(contributorURL).getRequest(),
            let _ = contributorsrequest.urlRequest.url else {
                response?(nil)
                return
        }
        
        let contributorNetworkOperation = RequestData(withURLRequest: contributorsrequest, andNetworkingProvider: httpWorker)
        contributorNetworkOperation.qualityOfService = .userInitiated
        contributorNetworkOperation.completionBlock = {
            if contributorNetworkOperation.error != nil {
                print("<ContributorSearchService> Error in HTTP : [StatusCode : \(String(describing: contributorNetworkOperation.response?.urlResponse.statusCode))] : <error  [\(String(describing: contributorNetworkOperation.error))]>")
                response?(nil)
                return
            }
            guard let httpResponse = contributorNetworkOperation.response, let data = httpResponse.data else{
                response?(nil)
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let contributors = try decoder.decode([Contributors].self, from: data)
                if contributors.count > 0 {
                    response?(contributors)
                }else{
                    print("<ContributorSearchService> Error : No data found")
                    response?(nil)
                }
            }catch let error {
                print("<ContributorSearchService> Error while parsing : [\(error.localizedDescription)]")
                response?(nil)
            }
        }
        operationQueue.addOperations([contributorNetworkOperation], waitUntilFinished: false)
    }
}
