//
//  API.swift
//  A1
//
//  Created by Nate Parrott on 3/18/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation
import Firebase

class API {
    static let Shared = API()
    
    init() {
//        if let existingUid = UserDefaults.standard.string(forKey: "uid") {
//            uid = existingUid
//        } else {
//            uid = NSUUID().uuidString
//            UserDefaults.standard.set(uid, forKey: "uid")
//        }
        uid = "uid1" // REMOVE
        feed = db.collection("Users").document(uid).collection("feed").order(by: "timestamp", descending: true)
    }
    
    let db = Firebase.Firestore.firestore()
    
    var feed: Query!
    
    let uid: String
    let baseURL = "https://a1-webapp-2.appspot.com"
    
    // callback comes on arbitrary thread
    func request(method: String, endpoint: String, params: [String: String], completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        var comps = URLComponents(string: baseURL + endpoint)!
        comps.queryItems = Array(params.keys.map({ URLQueryItem(name: $0, value: params[$0]!) }))
        var req = URLRequest(url: comps.url!)
        req.httpMethod = method
        URLSession.shared.dataTask(with: req, completionHandler: completion).resume()
    }
    
    // callback comes on arbitrary thread
    func subscribe(handle: String, completion: @escaping (Bool) -> ()) {
        request(method: "POST", endpoint: "/subscribe", params: ["user_id": uid, "handle": handle]) { (_, respOpt, _) in
            if let resp = respOpt as? HTTPURLResponse {
                completion(resp.statusCode == 200)
            } else {
                completion(false)
            }
        }
    }
}
