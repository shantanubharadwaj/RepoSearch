//
//  URLConfiguration.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

enum URLConfiguration {
    /**
     // - parameter programmingLanguage: Provide programming language to search for repo.
     */
    case searchRequest(String)
    // pass url to perform a general http request
    case generalRequest(URL)
    // pass contributors url received from initial repo search
    case contributorSearch(URL)
    // pass issues url received from initial repo search
    case issuesSearch(URL)
    
    
    /// generated Http Request to perform the request
    func getRequest() -> Http.Request? {
        switch self {
        case let .searchRequest(language):
            return search(language)
        case let .generalRequest(nextUrl):
            return generalRequest(nextUrl)
        case let .contributorSearch(searchURL):
            return repoDetails(searchURL, requestType: .searchContributors)
        case let .issuesSearch(searchURL):
            return repoDetails(searchURL, requestType: .searchIssues)
        }
    }
    
    private enum APIRequestValues {
        case scheme
        case host
        case authorization
        case search
        case repo
        
        func get() -> String {
            switch self {
            case .scheme:
                return "https"
            case .host:
                return "api.github.com"
            case .authorization:
                return "authorizations"
            case .search:
                return "search"
            case .repo:
                return "repositories"
            }
        }
    }
    
    enum RequestType {
        case searchRepo
        case searchContributors
        case searchIssues
    }
    
    private enum ParamInfo {
        case language(String)
        case sort(RequestType)
        case order
        case perPage
        
        func get() -> (key:String,value:String) {
            switch self {
            case let .language(language):
                return ("q","language:\(language)")
            case let .sort(requestType):
                switch requestType{
                case .searchRepo:
                    return ("sort","stars")
                case .searchContributors:
                    return ("sort","contributions")
                case .searchIssues:
                    return ("sort","updated_at")
                }
            case .order:
                return ("order","desc")
            case .perPage:
                return ("per_page","5")
            }
        }
    }
    
    private var productName: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String)
    }
    
    private var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier!
    }
    
    fileprivate func generalRequest(_ url: URL) -> Http.Request? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = Http.Constants.httpGet.get()
        var request = Http.Request(request: urlRequest)
        request.autoRedirects = true
        request.userAgent = productName
        let userService = CoreService().userService
        if userService.isUserAuthorized {
            var headers = [Http.Constants.accept.get(): Http.Constants.accept.getValue(), Http.Constants.userAgent.get():productName]
            if let token = userService.userToken {
                let headerValue = "token \(token)"
                headers[Http.Constants.authorization.get()] = headerValue
            }else if let userCreds = userService.userCredentials{
                let tokenValue = "\(userCreds.userName):\(userCreds.password)".base64Encode()
                let headerValue = "Basic \(tokenValue)"
                headers[Http.Constants.authorization.get()] = headerValue
            }
            request.headers = headers
        }
        return request
    }
    
    fileprivate func repoDetails(_ url: URL, requestType: RequestType) -> Http.Request? {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = [URLQueryItem]()
        let sortParam = ParamInfo.sort(requestType).get()
        items.append(URLQueryItem(name: sortParam.key, value: sortParam.value))
        items.append(URLQueryItem(name: ParamInfo.order.get().key, value: ParamInfo.order.get().value))
        items.append(URLQueryItem(name: ParamInfo.perPage.get().key, value: ParamInfo.perPage.get().value))
        items = items.filter{!$0.name.isEmpty}
        if !items.isEmpty {
            urlComponents?.queryItems = items
        }
        guard let url = urlComponents?.url else {
            print("Failed to form Repo Search request URL")
            return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = Http.Constants.httpGet.get()
        var request = Http.Request(request: urlRequest)
        request.autoRedirects = true
        request.userAgent = productName
        let userService = CoreService().userService
        if userService.isUserAuthorized {
            var headers = [Http.Constants.accept.get(): Http.Constants.accept.getValue(), Http.Constants.userAgent.get():productName]
            if let token = userService.userToken {
                let headerValue = "token \(token)"
                headers[Http.Constants.authorization.get()] = headerValue
            }else if let userCreds = userService.userCredentials{
                let tokenValue = "\(userCreds.userName):\(userCreds.password)".base64Encode()
                let headerValue = "Basic \(tokenValue)"
                headers[Http.Constants.authorization.get()] = headerValue
            }
            request.headers = headers
        }
        return request
    }
    
    fileprivate func search(_ language: String) -> Http.Request?{
        var urlComponents = URLComponents()
        urlComponents.scheme = APIRequestValues.scheme.get()
        urlComponents.host = APIRequestValues.host.get()
        
        var items = [URLQueryItem]()
        let languageParam = ParamInfo.language(language).get()
        let sortParam = ParamInfo.sort(.searchRepo).get()
        items.append(URLQueryItem(name: languageParam.key, value: languageParam.value))
        items.append(URLQueryItem(name: sortParam.key, value: sortParam.value))
        items.append(URLQueryItem(name: ParamInfo.order.get().key, value: ParamInfo.order.get().value))
        //        items.append(URLQueryItem(name: "per_page", value: "1"))
        items = items.filter{!$0.name.isEmpty}
        if !items.isEmpty {
            urlComponents.queryItems = items
        }
        
        guard let url = urlComponents.url?.appendingPathComponent(APIRequestValues.search.get()).appendingPathComponent(APIRequestValues.repo.get()) else {
            print("Failed to form Search request URL")
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = Http.Constants.httpGet.get()
        var request = Http.Request(request: urlRequest)
        request.autoRedirects = true
        request.userAgent = productName
        let userService = CoreService().userService
        if userService.isUserAuthorized {
            var headers = [Http.Constants.accept.get(): Http.Constants.accept.getValue(), Http.Constants.userAgent.get():productName]
            if let token = userService.userToken {
                let headerValue = "token \(token)"
                headers[Http.Constants.authorization.get()] = headerValue
            }else if let userCreds = userService.userCredentials{
                let tokenValue = "\(userCreds.userName):\(userCreds.password)".base64Encode()
                let headerValue = "Basic \(tokenValue)"
                headers[Http.Constants.authorization.get()] = headerValue
            }
            request.headers = headers
        }
        return request
    }
    
    //    https://api.github.com/search/repositories?q=language:swift&sort=stars&order=desc&per_page=2
    //
    //    Top 5 contributors
    //    https://api.github.com/repos/Alamofire/Alamofire/contributors?sort=contributions&order=desc&per_page=5
    //
    //    Accept : application/json
    //    User-Agent : <username>
    //    Top 2 issues
    //    https://api.github.com/repos/Alamofire/Alamofire/issues?sort=created_at&order=desc&per_page=2
}
