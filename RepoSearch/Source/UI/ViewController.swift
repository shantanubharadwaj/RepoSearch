//
//  ViewController.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 15/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchTerm: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func searchButton(_ sender: UIButton) {
        guard let searchValue = searchTerm.text, !searchValue.isEmpty else { print("Please enter some valid language values"); return }
        if let request = SearchRepoService(searchValue){
            request.fetch { [weak self] response in
                if let validResponse = response {
                    OperationQueue.main.addOperation {[weak self] in
                        self?.textView.text = validResponse.description
                    }
                }
            }
        }else{
            // throw alert to try after some time
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
        searchTerm.text = ""
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

