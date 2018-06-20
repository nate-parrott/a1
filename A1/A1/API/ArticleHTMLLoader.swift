//
//  ArticleHTMLLoader.swift
//  A1
//
//  Created by Nate Parrott on 6/20/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation

private func _loadMercuryContent(canonicalUrl: String, completion: @escaping ((String?) -> ())) {
    API.Shared.db.collection("MercuryContent").whereField("url", isEqualTo: canonicalUrl)
.getDocuments() { (snapshot, err) in
    if let doc = snapshot?.documents.first, let content = doc.data()["content"] as? String {
        let header = try! String(contentsOfFile: Bundle.main.path(forResource: "RawHTMLHeader", ofType: "html")!)
        completion(header + content)
    } else {
        completion(nil)
    }
    }
}

func loadArticleHTML(article: API.Article, priority: RequestManager.Priority, points: RequestManager.Points, completion: @escaping Loadable.Completion) -> Loadable? {
    guard let urlStr = article.amp_url ?? article.url, let url = URL(string: urlStr) else { return nil }
    let key = "loadArticleHTML:\(urlStr)"
    let isMercury = urlStr.starts(with: "https://mercury.postlight.com/amp?")
    if isMercury, let canonicalUrl = article.canonical_url {
        return Loadable(key: key, points: points, priority: priority, load: { (completion) in
            _loadMercuryContent(canonicalUrl: canonicalUrl, completion: { (strOpt) in
                completion(strOpt?.data(using: .utf8), nil)
            })
        }, alreadyInflight: false, completionQueue: DispatchQueue.main, completion: completion)
    } else {
        // fetch the article HTML via NSURLSession:
        return Loadable(key: key, points: points, priority: priority, load: { (completion) in
            URLSession.shared.dataTask(with: url, completionHandler: { (dataOpt, _, errOpt) in
                completion(dataOpt, errOpt)
            }).resume()
        }, alreadyInflight: false, completionQueue: DispatchQueue.main, completion: completion)
    }
}
