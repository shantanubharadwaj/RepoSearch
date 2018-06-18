//
//  License.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 16/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

struct License: Decodable {
    let key: String
    let name: String
    var url: URL?
}
