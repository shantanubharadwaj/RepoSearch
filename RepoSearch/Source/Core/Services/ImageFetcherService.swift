//
//  ImageFetcherService.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation
import UIKit

/// ImageFetcherService wraps the networks confguration formation and call to fetch image data based on passed image url.
class ImageFetcherService {
    fileprivate let httpWorker = Http.create("ImageService")
    private let operationQueue = OperationQueue()
    private let imageURL: URL
    
    /// pass url of image to be passed
    init(url: URL) {
        imageURL = url
    }
    
    func fetch(_ response: ((UIImage?) -> ())?){
        guard let request = URLConfiguration.generalRequest(imageURL).getRequest(), let _ = request.urlRequest.url else {
            response?(nil)
            return
        }
        
        let networkOperation = RequestData(withURLRequest: request, andNetworkingProvider: httpWorker)
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
