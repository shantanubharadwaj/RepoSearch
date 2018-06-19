//
//  Contributors.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

// Model for Contributors
struct Contributors: Decodable, CustomStringConvertible {
    let loginId: String
    var avatarURL: URL?
    var userProfile: URL?
    let contributions: Int
    
    enum CodingKeys: String, CodingKey {
        case loginId = "login"
        case avatarURL = "avatar_url"
        case userProfile = "html_url"
        case contributions
    }
    
    var description: String{
        return ""
    }
}
