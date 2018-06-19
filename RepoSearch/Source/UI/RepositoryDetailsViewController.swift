//
//  RepositoryDetailsViewController.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 6/18/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import UIKit

// Controller for Repository Details Display. This will display the Repository details along with top 10 contributors list and recently raised issues.
class RepositoryDetailsViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoDescription: UILabel!
    
    let issuesCellIdentifier = "IssueCell"
    let contributorCellIdentifier = "ContributorCell"
    
    var repoDetails: Repository?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = false
        containerView.clipsToBounds = true
        detailsTableView.isHidden = true
        detailsTableView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        detailsTableView.backgroundView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var font = UIFont.preferredFont(forTextStyle: .headline).withSize(17)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font)
        let attributes = [NSAttributedStringKey.font: font]
        UINavigationBar.appearance().titleTextAttributes = attributes
        title = repoDetails?.name ?? "Repository"
    }
    
    // Update UI and reload table view
    private func updateUI() {
        if let repository = repoDetails {
            repoName.text = repository.fullname
            repoDescription.text = repository.repoDesc
            if let userImageUrl = repository.owner.avatarUrl {
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
            if let contributorSearchURL = repository.contributorsList{
                let contributorRequest = RepoDetailsInfoFetcher(contributors: contributorSearchURL)
                contributorRequest.fetchContributorList { [weak self] (contributors) in
                    if let list = contributors {
                        OperationQueue.main.addOperation {
                            self?.detailsTableView.isHidden = false
                            self?.sections.append(Section(sectionType: .contributors, expanded: false))
                            self?.contributors = list
                            self?.detailsTableView.reloadData()
                        }
                    }
                }
            }
            if let issueListURL = repository.issuesList{
                let issueRequest = RepoDetailsInfoFetcher(issueURL: issueListURL)
                issueRequest.fetchIssueList { [weak self] (issues) in
                    if let list = issues{
                        OperationQueue.main.addOperation {
                            self?.detailsTableView.isHidden = false
                            self?.sections.append(Section(sectionType: .issues, expanded: false))
                            self?.issues = list
                            self?.detailsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    private var contributors = Array<Contributors>() {
        didSet {
            let index = sections.index{$0.sectionType == .contributors}
            if let idx = index {
                sections[idx].list = contributors
                OperationQueue.main.addOperation {
                    self.detailsTableView.reloadData()
                }
            }
        }
    }
    
    private var issues = Array<Issues>(){
        didSet {
            let index = sections.index{$0.sectionType == .issues}
            if let idx = index {
                sections[idx].list = issues
                OperationQueue.main.addOperation {
                    self.detailsTableView.reloadData()
                }
            }
        }
    }
    
    private var sections = [Section]()
}

extension RepositoryDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (sections[indexPath.section].expanded) {
            var height: CGFloat = 0
            switch sections[indexPath.section].sectionType {
            case .issues:
                height = 140
            case .contributors:
                height = 100
            }
            return height
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderSectionView()
        var headerName: String = "<>"
        switch sections[section].sectionType {
        case .issues:
            headerName = "Issues"
        case .contributors:
            headerName = "Contributors"
        }
        header.initialise(title: headerName, section: section, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section].sectionType {
        case .issues:
            let issues = sections[indexPath.section].list[indexPath.row] as! Issues
            let issueURL = issues.issueURL
            if app.canOpenURL(issueURL){
                app.open(issueURL, options: [:], completionHandler: nil)
            }
        case .contributors:
            let contributors = sections[indexPath.section].list[indexPath.row] as! Contributors
            if let contributorURL = contributors.userProfile, app.canOpenURL(contributorURL){
                app.open(contributorURL, options: [:], completionHandler: nil)
            }
        }
    }
}

extension RepositoryDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch sections[indexPath.section].sectionType {
        case .issues:
            let issuecell = detailsTableView.dequeueReusableCell(withIdentifier: issuesCellIdentifier, for: indexPath) as! IssuesTVCell
            let issues = sections[indexPath.section].list[indexPath.row] as! Issues
            issuecell.issues = issues
            cell = issuecell
        case .contributors:
            let contributorcell = detailsTableView.dequeueReusableCell(withIdentifier: contributorCellIdentifier, for: indexPath) as! ContributorsTVCell
            let contributors = sections[indexPath.section].list[indexPath.row] as! Contributors
            contributorcell.contributors = contributors
            cell = contributorcell
        }
        return cell
    }
}

extension RepositoryDetailsViewController: ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderSectionView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        detailsTableView.beginUpdates()
        for i in 0 ..< sections[section].list.count {
            detailsTableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        detailsTableView.endUpdates()
    }
}
