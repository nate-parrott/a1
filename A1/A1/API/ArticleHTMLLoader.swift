//
//  ArticleHTMLLoader.swift
//  A1
//
//  Created by Nate Parrott on 6/20/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation

func loadArticleHTML(article: API.Article, priority: RequestManager.Priority, points: RequestManager.Points, completion: @escaping Loadable.Completion) -> Loadable? {
    guard let urlStr = article.amp_url ?? article.url, let url = URL(string: urlStr) else { return nil }
    let isMercury = urlStr.starts(with: "https://mercury.postlight.com/amp?")
    if isMercury && false {
        // TODO
        return nil
    } else {
        // fetch the article HTML via NSURLSession:
        return Loadable(key: "loadArticleHTML:\(urlStr)", points: points, priority: priority, load: { (completion) in
            URLSession.shared.dataTask(with: url, completionHandler: { (dataOpt, _, errOpt) in
                completion(dataOpt, errOpt)
            }).resume()
        }, alreadyInflight: false, completionQueue: DispatchQueue.main, completion: completion)
    }
}
