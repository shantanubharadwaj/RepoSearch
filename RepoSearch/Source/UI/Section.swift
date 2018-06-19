//
//  Section.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 6/18/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

protocol SectionListDelegate {}

struct Section {
    enum List {
        case contributors
        case issues
    }
    let sectionType: List
    var list: [SectionListDelegate]!
    var expanded: Bool!
    
    init(sectionType: Section.List, expanded: Bool) {
        self.sectionType = sectionType
        self.expanded = expanded
    }
}

extension Contributors: SectionListDelegate {}
extension Issues: SectionListDelegate {}
