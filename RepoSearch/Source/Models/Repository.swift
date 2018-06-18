//
//  Repository.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

struct Items: Decodable {
    let items: [Repository]
}

struct Repository: Decodable, CustomStringConvertible {
    
    let name: String
    let fullname: String
    let owner: Owner
    let repoDesc: String
    var gitHubURL: URL?
    var forksList: URL?
    var contributorsList: URL?
    var issuesList: URL?
    let created: Date
    let lastUpdated: Date
    let stars: Int
    let watchers: Int
    let forks: Int
    let openIssues: Int
    var license: License?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        fullname = try container.decode(String.self, forKey: .fullname)
        owner = try container.decode(Owner.self, forKey: .owner)
        repoDesc = try container.decode(String.self, forKey: .repoDesc)
        if let urlString = try container.decodeIfPresent(String.self, forKey: .gitHubURL), let url = URL(string: urlString) {
            gitHubURL = url
        }
        if let urlString = try container.decodeIfPresent(String.self, forKey: .forksList), let url = URL(string: urlString) {
            forksList = url
        }
        if let urlString = try container.decodeIfPresent(String.self, forKey: .contributorsList), let url = URL(string: urlString) {
            contributorsList = url
        }
        if let urlString = try container.decodeIfPresent(String.self, forKey: .issuesList), let url = Repository.removeInvalidInfoFromUrl(urlString) {
            issuesList = url
        }
        created = try container.decode(Date.self, forKey: .created)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        stars = try container.decode(Int.self, forKey: .stars)
        watchers = try container.decode(Int.self, forKey: .watchers)
        forks = try container.decode(Int.self, forKey: .forks)
        openIssues = try container.decode(Int.self, forKey: .openIssues)
        if let value = try container.decodeIfPresent(License.self, forKey: .license) {
            license = value
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullname = "full_name"
        case owner
        case repoDesc = "description"
        case gitHubURL = "html_url"
        case forksList = "forks_url"
        case contributorsList = "contributors_url"
        case issuesList = "issues_url"
        case created = "created_at"
        case lastUpdated = "updated_at"
        case stars = "stargazers_count"
        case license
        case forks
        case openIssues = "open_issues"
        case watchers
    }
    
    fileprivate static func removeInvalidInfoFromUrl(_ value: String) -> URL? {
        var url: URL?
        if let range = value.index(of: "{"){
            let trimmedUrl = String(value[..<range])
            url = URL(string: trimmedUrl)
        }
        return url
    }
    
    var description: String{
        return ""
    }
}
