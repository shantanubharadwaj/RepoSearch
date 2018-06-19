//
//  RepoSearchViewController.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import UIKit

private let reuseIdentifier = "RepoCell"

// Controller for Repository Search. Pass the language in search bar to search for correspondng repository. Displays the repository in collection view.
class RepoSearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate let sectionInsets = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    fileprivate let cellsectionInsets = UIEdgeInsets(top: 20.0, left: 15.0, bottom: 20.0, right: 15.0)
    fileprivate var currentSearchString = ""
    fileprivate var isSearchInProgress: Bool = false
    
    var footerView: RefreshFooterView?
    var isLoading = false
    let footerViewReuseIdentifier = "RefreshFooterView"
    
    private var repositories = [Array<Repository>](){
        didSet {
            print("New repo received : \(String(describing: repositories.first?.count))")
        }
    }
    
    
    internal func insertRepo(_ newRepos: [Repository]) {
        OperationQueue.main.addOperation {
            self.repositories.append(newRepos)
            self.collectionView.reloadData()
        }
        
        //        let indexPaths = Array(0...(newRepos.count-1)).map { IndexPath(item: $0, section: 0) }
        
        //        self.collectionView.insertItems(at: indexPaths)
        //        let dd = IndexSet
        
        //        self.collectionView.insertSections(In)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = getIndexPathForSelectedCell() {
            highlightCell(at: indexPath, shouldHighlight: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.contentInset = sectionInsets
        self.collectionView.register(UINib(nibName: "CustomFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewReuseIdentifier)
        var font = UIFont.preferredFont(forTextStyle: .headline).withSize(17)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font)
        let attributes = [NSAttributedStringKey.font: font]
        UINavigationBar.appearance().titleTextAttributes = attributes
        title = "RepoSearch"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "RepoSearch"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func highlightCell(at indexPath: IndexPath, shouldHighlight: Bool) {
        let cell = collectionView.cellForItem(at: indexPath)
        if shouldHighlight {
            cell?.contentView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }else{
            cell?.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }
    }
    
    func getIndexPathForSelectedCell() -> IndexPath? {
        var indexPath:IndexPath?
        if let indexpaths = collectionView.indexPathsForSelectedItems, indexpaths.count > 0 {
            indexPath = indexpaths.first
        }
        return indexPath
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 100.0
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold)
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0)
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            self.footerView?.animateFinal()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        let pullHeight  = fabs(diffHeight - frameHeight)
        if pullHeight <= 10.0
        {
            if (self.footerView?.isAnimatingFinal)! {
                self.isLoading = true
                self.footerView?.startAnimate()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer:Timer) in
                    let request = SearchRepoService()
                    self.isSearchInProgress = true
                    OperationQueue.main.addOperation {
                        if !UIApplication.shared.isNetworkActivityIndicatorVisible {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = true
                        }
                    }
                    request.fetchNextData({ [weak self] response  in
                        self?.isSearchInProgress = false
                        OperationQueue.main.addOperation {
                            if UIApplication.shared.isNetworkActivityIndicatorVisible {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        }
                        if let validResponse = response {
                            OperationQueue.main.addOperation {[weak self] in
                                self?.insertRepo(validResponse)
                            }
                        }
                        self?.isLoading = false
                    })
                })
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        title = ""
        if segue.identifier == "ShowDetailSegue", let indexPath = getIndexPathForSelectedCell(), let repoDetailVC = segue.destination as? RepositoryDetailsViewController {
            repoDetailVC.repoDetails = repositories[indexPath.section][indexPath.item]
        }
    }
}

extension RepoSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 1.0) {
            cell.alpha = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        highlightCell(at: indexPath, shouldHighlight: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        highlightCell(at: indexPath, shouldHighlight: false)
    }
}

extension RepoSearchViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if repositories.count > 0 {
            if let _ = collectionView.backgroundView {
                collectionView.backgroundView = nil
            }
            return repositories.count
        }else if !isSearchInProgress{
            // Displaying a message when the table is empty
            let messagelabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.bounds.size.width - 20, height: view.bounds.size.height))
            messagelabel.text = "Enter a programming language name in the searchbar..."
            messagelabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            messagelabel.numberOfLines = 0
            messagelabel.textAlignment = .center
            var font = UIFont.preferredFont(forTextStyle: .body).withSize(20)
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            messagelabel.font = font
            messagelabel.sizeToFit()
            
            collectionView.backgroundView = messagelabel
            collectionView.backgroundView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
            return 0
        }else{
            if let _ = collectionView.backgroundView {
                collectionView.backgroundView = nil
            }
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !repositories.isEmpty {
            return repositories[section].count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        let repo: Repository = repositories[indexPath.section][indexPath.item]
        if let repoCell = cell as? RepositoryViewCell {
            repoCell.repository = repo
        }
        return cell
    }
}

extension RepoSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = cellsectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! RefreshFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath)
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
}

extension RepoSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // start search from here
        guard let searchValue = searchBar.text, !searchValue.isEmpty else { print("Please enter some valid language values"); return }
        if currentSearchString != searchValue {
            repositories.removeAll()
            collectionView.reloadData()
            if let request = SearchRepoService(searchValue){
                isSearchInProgress = true
                OperationQueue.main.addOperation {
                    if !UIApplication.shared.isNetworkActivityIndicatorVisible {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    }
                }
                request.fetch { [weak self] response in
                    self?.isSearchInProgress = false
                    OperationQueue.main.addOperation {
                        if UIApplication.shared.isNetworkActivityIndicatorVisible {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                    if let validResponse = response {
                        OperationQueue.main.addOperation {[weak self] in
                            self?.insertRepo(validResponse)
                        }
                    }
                }
            }else{
                // throw alert to try after some time
                showAlert(withTitle: "Try after few seconds !!", buttonTitle: "Ok", andMessage: "The servers are busy. Please try after few seconds.")
            }
        }
        
    }
    
    func showAlert(withTitle title: String, buttonTitle: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
