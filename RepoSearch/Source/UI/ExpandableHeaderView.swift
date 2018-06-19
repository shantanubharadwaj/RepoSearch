//
//  ExpandableHeaderSectionView.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 6/18/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import UIKit

// Protocol to handle toggle events of sections
protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderSectionView, section: Int)
}

// Custom class to handle expandable header views for hiding/displaying sections
class ExpandableHeaderSectionView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        // Register for tap events in header view
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // call registered delegate to inform of toggle events.
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderSectionView
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func initialise(title: String, section: Int, delegate: ExpandableHeaderViewDelegate) {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.contentView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
}
