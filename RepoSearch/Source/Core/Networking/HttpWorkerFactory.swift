//
//  HttpWorkerFactory.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

extension Http{
    static func create(_ creator: String) -> HttpWorker {
        return NetworkConnector(creator)
    }
}
