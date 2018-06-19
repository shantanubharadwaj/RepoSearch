//
//  ContributorsTVCell.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 6/18/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import UIKit

// Custom table view Cell for Contributors 
class ContributorsTVCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var loginID: UILabel!
    @IBOutlet weak var contributions: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var contributors: Contributors? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let contributors = contributors {
            loginID.text = "   " + contributors.loginId
            contributions.text = "   Contributions : \(contributors.contributions)"
            
            if let userImageUrl = contributors.avatarURL {
                let request = ImageFetcherService(url: userImageUrl)
                OperationQueue.main.addOperation {
                    if !UIApplication.shared.isNetworkActivityIndicatorVisible {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    }
                }
                request.fetch { [weak self] avImage in
                    OperationQueue.main.addOperation {
                        if UIApplication.shared.isNetworkActivityIndicatorVisible {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                    if let image = avImage{
                        OperationQueue.main.addOperation {
                            self?.avatarImage.image = image
                        }
                    }
                }
            }else{
                avatarImage.image = UIImage(named: "defaultCellIcon")
            }
        }
        
        cellView.layer.cornerRadius = cellView.frame.size.height / 2
        cellView.layer.masksToBounds = true
        cellView.clipsToBounds = true
        avatarImage.layer.cornerRadius = avatarImage.frame.size.height / 2
        avatarImage.layer.masksToBounds = true
        avatarImage.clipsToBounds = true
    }
}
