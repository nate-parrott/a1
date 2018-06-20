//
//  ImageLoadable.swift
//  A1
//
//  Created by Nate Parrott on 6/20/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation

func createImageLoadable(url: URL, priority: RequestManager.Priority, completion: @escaping Loadable.Completion) -> Loadable {
    return Loadable(key: url.absoluteString, points: .normal, priority: priority, load: { (completion) in
        URLSession.shared.dataTask(with: url, completionHandler: { (dataOpt, _, errOpt) in
            guard let data = dataOpt, let image = UIImage(data: data) else {
                completion(nil, errOpt)
                return
            }
            completion(image, nil)
        }).resume()
    }, alreadyInflight: false, completionQueue: DispatchQueue.main, completion: completion)
}
