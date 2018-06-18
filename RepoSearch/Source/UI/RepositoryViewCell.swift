//
//  RepositoryViewCell.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import UIKit

class RepositoryViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cellBackground: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    var repository: Repository? { didSet { updateUI() } }
    
    private func updateUI() {
        guard let repo = repository else { return }
        captionLabel.text = repo.name
        starsLabel.text = "\(repo.stars) ⭐️"
        if let userImageUrl = repo.owner.avatarUrl {
            let request = ImageFetcherService(url: userImageUrl)
            request.fetch { [weak self] avImage in
                if let image = avImage{
                    OperationQueue.main.addOperation {
                        self?.avatarImage.image = image
                    }
                }
            }
        }else{
            avatarImage.image = UIImage(named: "defaultCellIcon")
        }
        
        formatImageView()
        updateCellView()
        updateBckImageView()
    }
    
    private func formatImageView(){
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2
        avatarImage.layer.masksToBounds = true
        avatarImage.clipsToBounds = true
        
        avatarImage.layer.borderWidth = 3.0
        avatarImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    private func updateCellView() {
        containerView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        containerView.layer.cornerRadius = 9.0
        containerView.layer.masksToBounds = false
        containerView.clipsToBounds = true
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 0.8
        
        self.contentView.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.contentView.layer.cornerRadius = 9.0
        self.contentView.layer.masksToBounds = false
        self.contentView.clipsToBounds = true
        self.contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.contentView.layer.shadowOpacity = 0.8
    }
    
    private func updateBckImageView() {
        cellBackground.layer.cornerRadius = 9.0
        cellBackground.layer.masksToBounds = true
        cellBackground.clipsToBounds = true
    }
}
