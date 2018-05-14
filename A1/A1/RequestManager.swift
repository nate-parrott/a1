//
//  RequestManager.swift
//  A1
//
//  Created by Nate Parrott on 5/9/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation
import BrightFutures
import Result

/// Declaratively manages requests, with prioritization and caching
class RequestManager {
    
    // TODO: Use Reachability to retry failed requests when we come back online
    
    // MARK: Types
    
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
    
    class Completion {
        init(queue: DispatchQueue, block: @escaping (Any?, Error?) -> ()) {
            self.queue = queue
            self.block = block
        }
        var _called = false
        let block: (Any?, Error?) -> ()
        let queue: DispatchQueue
        func _callIfNeeded(result: Any?, err: Error?) {
            guard !_called else { return }
            _called = true
            queue.async {
                self.block(result, err)
            }
        }
    }
    
    // MARK: init
    
    let shared = RequestManager()
    
    init() {
        
    }
    
    // MARK: Internal work
    // !! All internal work should be done on _queue
    
    let _queue = DispatchQueue(label: "RequestManager")
    var _loadables = [Loadable]() {
        didSet {
            _log("\n\nreceived \(_loadables.count) loadables")
            
            // immediately callback for cached loadables:
            for loadable in _loadables {
                if let cached = _cache.object(forKey: loadable.key as NSString) {
                    loadable.completion._callIfNeeded(result: cached.item, err: nil)
                }
            }
            
            // loadables that are `alreadyInflight` should be counted first:
            for loadable in _loadables {
                if loadable.alreadyInflight {
                    _startIfNeeded(loadable: loadable)
                }
            }
            _startLoadablesIfReady()
        }
    }
    
    func _startLoadablesIfReady() {
        _log("startLoadablesIfReady()")
        // compute how many points are already inflight:
        var remainingPoints: Float = 1
        for inflight in _inflight.values {
            remainingPoints -= inflight.points.rawValue
        }
        _log("\(_inflight.keys.count) inflight items worth \(1 - remainingPoints) points")
        // sort unstarted loadables by priority and start as many as we have left in our point budget:
        let toLoad = _loadables.filter({ _inflight[$0.key] == nil }).sorted { (l1, l2) -> Bool in
            return l1.priority.rawValue >= l2.priority.rawValue
        }
        for loadable in toLoad {
            remainingPoints -= loadable.points.rawValue
            if remainingPoints < 0 {
                break
            }
            _startIfNeeded(loadable: loadable)
        }
    }
    
    func _startIfNeeded(loadable: Loadable) {
        let key = loadable.key
        guard _inflight[key] == nil else { return }
        // add a task to the inflight dict:
        _inflight[key] = Task(key: key, points: loadable.points)
        // do the task:
        _log("Starting task \(key)")
        _ = loadable.load().andThen { [weak self] (result) in
            guard let `self` = self else { return }
            self._queue.async {
                if let successResult = result.value {
                    self._log("Task \(key) finished successfully")
                    // cache the result
                    self._cache.setObject(RequestManager.CacheObject(item: successResult), forKey: key as NSString)
                } else {
                    self._log("Task \(key) failed")
                }
                self._inflight.removeValue(forKey: key)
                // send callbacks:
                for loadable in self._loadables {
                    if loadable.key == key {
                        loadable.completion._callIfNeeded(result: result.value, err: result.error)
                    }
                }
                self._startLoadablesIfReady()
            }
        }
    }
    
    func _log(_ string: String) {
        print("🌎 \(string)")
    }
    
    struct Task {
        let key: String
        let points: Points
    }
    var _inflight = [String: Task]()
    var _cache = NSCache<NSString, CacheObject>()
    class CacheObject : NSObject {
        init(item: Any) {
            self.item = item
            super.init()
        }
        let item: Any
    }
    
    // MARK: API
    
    var loadables = [Loadable]() {
        didSet {
            let newLoadables = loadables
            _queue.async {
                self._loadables = newLoadables
            }
        }
    }
}

protocol Loadable {
    var key: String { get }
    var points: RequestManager.Points { get }
    var priority: RequestManager.Priority { get }
    func load() -> Future<Any, AnyError>
    var completion: RequestManager.Completion { get } // called on an arbitrary queue
    var alreadyInflight: Bool { get } // should be considered 'inflight' before load() is called upon it
}

