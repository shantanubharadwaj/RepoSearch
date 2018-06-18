//
//  HttpNetworkWorker.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

extension Http{
    fileprivate class RequestMetaData {
        var urlSession: URLSession
        var dataTask: URLSessionDataTask
        var httpRequest: Request
        var successHandler: Http.SuccessHandler
        var errorHandler: Http.ErrorHandler
        var data: Data?
        var httpURLResponse: HTTPURLResponse?
        
        init(_ request: Request, session: URLSession, task: URLSessionDataTask, success: @escaping Http.SuccessHandler, error: @escaping Http.ErrorHandler) {
            httpRequest = request
            urlSession = session
            dataTask = task
            successHandler = success
            errorHandler = error
        }
    }
    
    class NetworkConnector: NSObject, HttpWorker {
        fileprivate var creator: String = ""
        //Request Metadata Holder
        fileprivate var metaDataHolder = Dictionary<String, RequestMetaData>()
        
        init(_ creator: String){
            self.creator = creator
        }
        
        func send(_ request: Http.Request, success: @escaping Http.SuccessHandler, error: @escaping Http.ErrorHandler) {
            //cancel if the same request is already in progress.
            cancel(request)
            let headers = request.headers ?? [Http.Constants.accept.get(): Http.Constants.accept.getValue(), Http.Constants.userAgent.get():request.userAgent]
            let session = self.newSession(request, headers: headers)
            print("HTTPWorker[\(creator)]::sending http request:<\(request)>.")
            
//            request.urlRequest.setValue(Http.Constants.accept.getValue(), forHTTPHeaderField: Http.Constants.accept.get())
//            request.urlRequest.setValue(request.userAgent, forHTTPHeaderField: Http.Constants.userAgent.get())
            
            let dataTask = session.dataTask(with: request.urlRequest)
            dataTask.taskDescription = request.id.uuidString
            
            //create request meta data
            let requestMetaData = RequestMetaData(request, session: session, task: dataTask, success: success, error: error)
            self.setMetaData(requestMetaData, id: request.id.uuidString)
            print("HTTPWorker[\(self.creator)]::sessionConfiguration http headers:<\(String(describing: session.configuration.httpAdditionalHeaders))>.")
            print("HTTPWorker[\(self.creator)]::request http headers:<\(String(describing: request.urlRequest.allHTTPHeaderFields))>.")
            
            dataTask.resume()
        }
        
        fileprivate func newSession(_ request: Http.Request, headers: [AnyHashable : Any]?) -> Foundation.URLSession {
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = headers
            sessionConfiguration.timeoutIntervalForRequest = Http.Util.defaultHttpTimeout
            sessionConfiguration.timeoutIntervalForResource = Http.Util.defaultHttpTimeout
            
            //create a new session with this configuration
            let session = URLSession(configuration:sessionConfiguration, delegate:self, delegateQueue:nil)
            return session
        }
        
        @discardableResult
        func cancel(_ request: Http.Request) -> Bool {
            var result = false
            DispatchQueue.global().sync { [unowned self] in
                if let metaData = self.metaDataHolder[request.id.uuidString] {
                    metaData.dataTask.cancel()
                    metaData.urlSession.invalidateAndCancel()
                    result = true
                }
            }
            
            self.removeMetaData(request.id.uuidString)
            return result
        }
        
        @discardableResult
        func cancelAll() -> Bool {
            DispatchQueue.global().sync { [unowned self] in
                let values = Array(self.metaDataHolder.values)
                for metaData in values {
                    metaData.dataTask.cancel()
                    metaData.urlSession.invalidateAndCancel()
                }
            }
            
            removeAllMetaData()
            return true
        }
        
        //MARK:- Meta Data
        fileprivate func metaData(_ id: String) -> RequestMetaData? {
            var metaData: RequestMetaData?
            DispatchQueue.global().sync { [unowned self] in
                print("HTTPWorker[\(self.creator)]::returning metadata for: \(id)")
                metaData = self.metaDataHolder[id]
            }
            
            return metaData
        }
        
        fileprivate func setMetaData(_ metaData: RequestMetaData, id: String){
            DispatchQueue.global().sync { [unowned self] in
                print("HTTPWorker[\(self.creator)]::setting new meta data for: \(id)")
                self.metaDataHolder[id] = metaData
                print("HTTPWorker[\(self.creator)]::active requests after set: \(Array(self.metaDataHolder.keys))")
            }
        }
        
        fileprivate func initializeData(_ id: String) {
            DispatchQueue.global().sync { [unowned self] in
                if let metaData = self.metaDataHolder[id] {
                    metaData.data = Data()
                }
            }
        }
        
        fileprivate func appendDataForRequest(_ data: Data, id: String){
            DispatchQueue.global().sync { [unowned self] in
                if let metaData = self.metaDataHolder[id] {
                    metaData.data?.append(data)
                }
            }
        }
        
        fileprivate func removeMetaData(_ id: String) {
            DispatchQueue.global().sync { [unowned self] in
                print("HTTPWorker[\(self.creator)]::removing meta data for: \(id)")
                self.metaDataHolder.removeValue(forKey: id)
            }
        }
        
        fileprivate func removeAllMetaData(){
            DispatchQueue.global().sync { [unowned self] in
                print("HTTPWorker[\(self.creator)]::removing all meta data.")
                self.metaDataHolder.removeAll()
            }
        }
    }
}

extension Http.NetworkConnector: URLSessionDataDelegate{
    //MARK:- URLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?){
        print("HTTPWorker[\(self.creator)]::session became invalid with error:<\(String(describing: error))>")
    }
    
    //MARK:- URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        
        if let metaData = self.metaData(task.taskDescription!) {
            let httpRequest = metaData.httpRequest
            if let validerror = error as NSError?{
                if isRedirect(statusCode: metaData.httpURLResponse?.statusCode), let validResponse = metaData.httpURLResponse {
                    let httpResponse = Http.Response(httpResponse:validResponse, data:nil)
                    metaData.urlSession.finishTasksAndInvalidate()
                    metaData.successHandler(metaData.httpRequest, httpResponse)
                    self.removeMetaData(metaData.httpRequest.id.uuidString)
                }else{
                    metaData.urlSession.finishTasksAndInvalidate()
                    metaData.errorHandler(httpRequest, Http.Error(code: validerror.code, errorDescription: validerror.localizedDescription))
                    self.removeMetaData(metaData.httpRequest.id.uuidString)
                }
            }else{
                if let validResponse = metaData.httpURLResponse {
                    print("HTTPWorker[\(String(describing: self.creator))]::valid response present, returning success. Data length: \(String(describing: metaData.data?.count)).)")
                    let httpResponse = Http.Response(httpResponse: validResponse, data: metaData.data
                        , finalURL: validResponse.url)
                    metaData.urlSession.finishTasksAndInvalidate()
                    metaData.successHandler(httpRequest, httpResponse)
                    self.removeMetaData(metaData.httpRequest.id.uuidString)
                }else{
                    print("HTTPWorker[\(self.creator)]::invalid response present, returning success.")
                    metaData.urlSession.finishTasksAndInvalidate()
                    metaData.errorHandler(httpRequest, Http.Error(code: Http.ErrorCodes.invalidResponse.rawValue))
                    self.removeMetaData(metaData.httpRequest.id.uuidString)
                }
            }
        }else{
            print("HTTPWorker[\(self.creator)]::failed to get meta data of the request, error.")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let metaData = self.metaData(task.taskDescription!){
            metaData.httpURLResponse = response
            print("HTTPWorker[\(self.creator)]::should perform auto redirect:<\(metaData.httpRequest.autoRedirects)> to request:<\(request)>")
            
            if metaData.httpRequest.autoRedirects {
                print("HTTPWorker[\(self.creator)]willPerformHTTPRedirection:: called the completion handler for auto redirect")
                completionHandler(request)
            }else{
                completionHandler(nil)
                print("HTTPWorker[\(self.creator)]willPerformHTTPRedirection:: called the completion handler")
                
            }
        }else{
            completionHandler(nil)
            print("HttpWorker[\(self.creator)]::URLSession(session,task,willPerformHTTPRedirection,newRequest,completionHandler)::failed to get meta data of the request, error.")
        }
    }
    
    //MARK:- URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        print("HTTPWorker[\(self.creator)]::did receive response:<\(response)>")
        
        if let metaData = self.metaData(dataTask.taskDescription!){
            guard let validResponse = response as? HTTPURLResponse else {
                print("HttpWorker[\(self.creator)]::failed to unwrap response, canceling HTTP.")
                metaData.urlSession.finishTasksAndInvalidate()
                metaData.errorHandler(metaData.httpRequest, Http.Error(code: Http.ErrorCodes.invalidResponse.rawValue))
                self.removeMetaData(dataTask.taskDescription!)
                
                completionHandler(.cancel)
                return
            }
            
            metaData.httpURLResponse = validResponse
            self.initializeData(metaData.httpRequest.id.uuidString)
            
            print("HttpWorker[\(self.creator)]::valid response, proceeding with the HTTP request.")
            completionHandler(.allow)
        }else{
            completionHandler(.cancel)
            print("HttpWorker[\(self.creator)]::URLSession(session,dataTask,didReceiveResponse,completionHandler):: failed to get meta data of the request, error.")
            return
        }
    }
    
    private func isRedirect(statusCode: Int?) -> Bool {
        return ((statusCode == Http.RedirectHttpCode.movedPermanently.code()) || (statusCode == Http.RedirectHttpCode.movedTemporarily.code()) || (statusCode == Http.RedirectHttpCode.permanentRedirect.code()) || (statusCode == Http.RedirectHttpCode.temporaryRedirect.code()))
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        appendDataForRequest(data, id: dataTask.taskDescription!)
    }
}
