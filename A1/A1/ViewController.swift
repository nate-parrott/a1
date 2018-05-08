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
            if s._paginator.hasNew {
                s._paginator.refresh()
            }
            
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
        
        articlesView.onTapArticle = { [weak self] (article) in
            self?.show(article: article)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _paginator.refresh()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        title = dateFormatter.string(from: Date())
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
    
    func show(article: API.Article) {
        let articleVC = ArticleViewController(nibName: nil, bundle: nil)
        articleVC.article = article
        articleVC.presentFrom(parent: self)
    }
    
    @IBAction func tappedSubscribe(sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "New Subscription", message: "Enter a Twitter handle to subscribe to:", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Subscribe", style: .default, handler: { (_) in
            guard let handleRaw = controller.textFields!.first!.text else { return }
            let handle = handleRaw.replacingOccurrences(of: "@", with: "")
            guard handle.count > 0 else { return }
            API.Shared.subscribe(handle: handle, completion: { (success) in
                DispatchQueue.main.async {
                    if !success {
                        let alert = UIAlertController(title: nil, message: "Failed to subscribe", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addTextField { (field) in
            field.placeholder = "@nytimes"
            field.keyboardType = .twitter
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
        }
        present(controller, animated: true, completion: nil)
    }
}
