//
//  PreloadingHelpers.swift
//  A1
//
//  Created by Nate Parrott on 6/20/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation

struct PreloadingHelpers {
    static let queue = DispatchQueue(label: "RequestManager")
}

func createFullContentPreloadables(sections: [SectionedArticleView.Section]) -> [Loadable] {
    var preloadables = [Loadable]()
    
    for (sectionIdx, section) in sections.enumerated() {
        for (articleIdx, article) in section.articles.enumerated() {
            guard let imageUrlStr = article.lead_image_url, let imageUrl = URL(string: imageUrlStr) else { continue }
            let distanceFromTopScreen = max(0, sectionIdx - 3) + articleIdx
            let priority = RequestManager.Priorities.preloadLater - Float(distanceFromTopScreen) / 100
            preloadables.append(createImageLoadable(url: imageUrl, priority: priority, completion: { (_, _) in
                ()
            }))
        }
    }
    
    return preloadables
}

func preloadArticleForImminentDisplay(_ article: API.Article) {
    if let imageStr = article.lead_image_url, let imageUrl = URL(string: imageStr) {
        RequestManager.shared.load(createImageLoadable(url: imageUrl, priority: RequestManager.Priorities.preloadSoon, completion: { (_, _) in
            ()
        }))
    }
    if let htmlLoadable = loadArticleHTML(article: article, priority: RequestManager.Priorities.preloadSoon, points: RequestManager.Points.normal, completion: { (_, _) in
    }) {
        RequestManager.sharedForArticleHTML.load(htmlLoadable)
    }
}
