//
//  UserInformation.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

// User information data fetched after authentication data
// TODO: Implementing user authentication pending...
protocol UserInformation {
    var userCredentials: (userName: String, password: String)? { get }
    var userToken: (String)? { get }
    var isUserAuthorized: Bool { get}
}

struct UserInfo: UserInformation {
    var userCredentials: (userName: String, password: String)? {
        return nil
    }
    
    var userToken: (String)? {
        return nil
    }
    
    var isUserAuthorized: Bool{
        return false
    }
}
