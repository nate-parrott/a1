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
}
