//
//  ImageFetcherService.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation
import UIKit

class ImageFetcherService {
    fileprivate let httpWorker = Http.create("SearchService")
    private let operationQueue = OperationQueue()
    private let imageURL: URL
    
    init(url: URL) {
        imageURL = url
    }
    
    func fetch(_ response: ((UIImage?) -> ())?){
        guard let nextrequest = URLConfiguration.generalRequest(imageURL).getRequest(), let _ = nextrequest.urlRequest.url else {
            response?(nil)
            return
        }
        
        let networkOperation = RequestData(withURLRequest: nextrequest, andNetworkingProvider: httpWorker)
        networkOperation.qualityOfService = .userInitiated
        
        networkOperation.completionBlock = {
            if networkOperation.error != nil {
                print("<ImageFetcherService> : Error in HTTP : [StatusCode : \(String(describing: networkOperation.response?.urlResponse.statusCode))] : <error  [\(String(describing: networkOperation.error))]>")
                response?(nil)
                return
            }
            guard let httpResponse = networkOperation.response, let responseData = httpResponse.data else{
                response?(nil)
                return
            }

            if let image = UIImage(data: responseData) {
                response?(image)
            }else{
                print("<ImageFetcherService> Error while converting data to image")
                response?(nil)
            }
        }
        
        operationQueue.addOperations([networkOperation], waitUntilFinished: false)
    }
}
