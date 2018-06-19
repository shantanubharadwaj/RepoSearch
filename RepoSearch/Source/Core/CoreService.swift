//
//  CoreService.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

// Core service to provide interface to all the internal services
struct CoreService {
    var userService: UserInformation {
        return UserInfo()
    }
}
