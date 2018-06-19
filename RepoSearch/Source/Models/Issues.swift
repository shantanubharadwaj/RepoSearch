//
//  Issues.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

// Model for Issue
struct Issues: Decodable, CustomStringConvertible {
    
    let title: String
    let issueURL: URL
    let issueNumber: Int
    let user: IssueUser
    var comments: Int?
    let created: Date
    let updated: Date
    let isOpen: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case issueURL = "html_url"
        case issueNumber = "number"
        case user
        case comments
        case created = "created_at"
        case updated = "updated_at"
        case isOpen = "state"
    }
    
    var openedTime: String {
        let time = (updated.timeIntervalSinceNow * (-1))
        let timeInMins = (time / 60)
        if timeInMins < 0 {
            return "\(time) seconds ago"
        }else{
            let timeinhrs = timeInMins / 60
            if timeinhrs < 0 {
                return "\(timeInMins) minutes ago"
            }else{
                let days = timeinhrs / 24
                if days < 0 {
                    return "\(timeinhrs) hours ago"
                }else{
                    return "\(days) days ago"
                }
            }
        }
    }
    
    var description: String{
        return ""
    }
}

struct IssueUser: Decodable {
    let loginId: String
    
    enum CodingKeys: String, CodingKey {
        case loginId = "login"
    }
}
