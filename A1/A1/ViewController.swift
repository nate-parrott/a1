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
            
            let articles = s._paginator.documents.map({ API.Article.from(document: $0)! })
            var allSources = [String]()
            var articlesBySource = [String: [API.Article]]()
            for article in articles {
                guard let source = article.first_source else { continue }
                if articlesBySource[source] == nil {
                    allSources.append(source)
                    articlesBySource[source] = [article]
                } else {
                    articlesBySource[source]!.append(article)
                }
            }
            let sections = allSources.map({ SectionedArticleView.Section(title: $0, articles: articlesBySource[$0]!) })
            s.articlesView.sections = sections
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _paginator.refresh()
    }
    
    var _paginator: API.Paginator!
    
    let articlesView = SectionedArticleView()

    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        articlesView.frame = view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
