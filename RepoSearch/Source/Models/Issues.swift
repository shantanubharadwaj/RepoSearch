//
//  Issues.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

struct IssueList {
    let issueList: [Issues]
}

struct Issues: Decodable, CustomStringConvertible {
    
    let title: String
    let issueURL: URL
    let issueNumber: Int
    let user: IssueUser
    let created: Date
    
    enum CodingKeys: String, CodingKey {
        case title
        case issueURL = "html_url"
        case issueNumber = "number"
        case user
        case created = "created_at"
    }
    
    var description: String{
        return ""
    }
}

struct IssueUser: Decodable {
    let loginId: String
    let avatarURL: URL
    let userProfile: URL
    
    enum CodingKeys: String, CodingKey {
        case loginId = "login"
        case avatarURL = "avatar_url"
        case userProfile = "html_url"
    }
}
