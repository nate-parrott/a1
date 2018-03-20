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
        _paginator = API.Paginator(query: API.Shared.feed)
        _paginator.onUpdate = { [weak self] in
            guard let s = self else { return }
            s.articlesView.articles = s._paginator.documents.map({ API.Article.from(document: $0)! })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _paginator.refresh()
    }
    
    var _paginator: API.Paginator!
    
    let articlesView = ArticlesView()

    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        articlesView.frame = view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
