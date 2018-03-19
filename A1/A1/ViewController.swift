//
//  ViewController.swift
//  A1
//
//  Created by Nate Parrott on 3/18/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(articlesView)
    }
    
    let articlesView = ArticlesView()

    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        articlesView.frame = view.bounds
    }
}
