//
//  RequestManager.swift
//  A1
//
//  Created by Nate Parrott on 5/9/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation
// import BrightFutures

/// Manages the prioritization of requests
class RequestManager {
    enum Priority: Float {
        case immediate = 10
        case preloadSoon = 5
        case preloadLater = 4
        case optional = 1
    }
    enum Points: Float {
        case all = 1 // no other requests allowed
        case normal = 0.2 // allow 5 concurrent requests
    }
    
    func enqueue(request: Request, priority: Priority, alreadyStarted: Bool) {
        
    }
    
    var _queue = DispatchQueue(label: "RequestManager")
    var _inFlight = [Request]()
    var _enqueued = [Request]()
}

protocol Request {
    var key: String { get }
    var points: RequestManager.Points { get }
    func start()
    func cancel() -> Bool
    // finished future
}
