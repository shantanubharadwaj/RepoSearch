//
//  IssuesTVCell.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 6/18/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import UIKit

// Custom class for issues table view cell
class IssuesTVCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var issueTitle: UILabel!
    @IBOutlet weak var issueNumber: UILabel!
//    @IBOutlet weak var updatedDate: UILabel!
    @IBOutlet weak var userID: UILabel!
//    @IBOutlet weak var createdDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var issues: Issues? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let issues = issues {
            issueTitle.text = issues.title
            
            var font = UIFont(name: "Courier New", size: 17) ?? UIFont.preferredFont(forTextStyle: .title2).withSize(17)
            font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: font)
            let attributes = [NSAttributedStringKey.font: font]
            
            issueNumber.attributedText = NSAttributedString(string: "Issue : #\(issues.issueNumber) opened \(issues.openedTime)", attributes: attributes)
            let createdDate = issues.created
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let date = dateFormatter.string(from: createdDate)
            userID.attributedText = NSAttributedString(string: "Created by: \(issues.user.loginId) on \(date)", attributes: attributes)
            
            containerView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            containerView.layer.cornerRadius = 5.0
            containerView.layer.masksToBounds = true
            containerView.clipsToBounds = true
            containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
            containerView.layer.shadowOpacity = 0.8
        }
    }
}
