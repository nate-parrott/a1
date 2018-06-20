//
//  API+Article.swift
//  A1
//
//  Created by Nate Parrott on 3/20/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation
import Firebase

extension API {
    class Article : Codable {
        static func from(document: DocumentSnapshot) -> Article? {
            guard let dict = document.data() else { return nil }
            guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else { return nil }
            return try? JSONDecoder().decode(API.Article.self, from: data)
        }
        var amp_url: String?
        var canonical_url: String?
        var dek: String?
        var title: String?
        var url: String?
        var first_source: String?
        var lead_image_url: String?
    }
}
