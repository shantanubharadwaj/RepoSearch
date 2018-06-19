//
//  License.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

// Model for License of the repo
struct License: Decodable {
    let key: String
    let name: String
    var url: URL?
}
