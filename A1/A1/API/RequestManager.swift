//
//  RequestManager.swift
//  A1
//
//  Created by Nate Parrott on 5/9/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation

/// Declaratively manages requests, with prioritization and caching
class RequestManager {
    
    // TODO: Use Reachability to retry failed requests when we come back online
    
    // MARK: Types
    typealias Priority = Float
    struct Priorities {
        static let immediate: Priority = 10
        static let userVisible: Priority = 8
        static let preloadSoon: Priority = 5
        static let preloadLater: Priority = 4
        static let optional: Priority = 1

    }
    
    enum Points: Float {
        case all = 1 // no other requests allowed
        case normal = 0.1 // allow 10 concurrent requests
    }
    
    // MARK: init
    
    static let shared = RequestManager()
    static let sharedForArticleHTML = RequestManager()
    
    init() {
        
    }
    
    // MARK: Internal work
    // !! All internal work should be done on _queue
    
    let _queue = DispatchQueue(label: "RequestManager")
    var _pending = Set<Loadable>()
    var _remainingPoints: Float = 1
    
    func _startPendingLoadablesIfAppropriate() {
        _log("_startPendingLoadablesIfAppropriate()")
        if _pending.count == 0 {
            _log("No pending items 👌")
        }
        guard _remainingPoints > 0 else { return }
        // sort unstarted loadables by priority and start as many as we have left in our point budget:
        let toLoad = _pending.filter({ _inflight[$0.key] == nil }).sorted { (l1, l2) -> Bool in
            return l1.priority >= l2.priority
        }
        // TODO: put pending requests in a heap so we don't need to re-sort every time
        for loadable in toLoad {
            guard _inflight[loadable.key] == nil else { continue }
            if _remainingPoints - loadable.points.rawValue < 0 {
                break
            }
            _kickOff(loadable: loadable)
        }
    }
    
    func _kickOff(loadable: Loadable) {
        let key = loadable.key
        // add a task to the inflight dict:
        _inflight[key] = Task(key: key, points: loadable.points)
        _remainingPoints -= loadable.points.rawValue
        // do the task:
        _log("Starting task \(key)")
        loadable.load() { [weak self] (result, err) in
            guard let `self` = self else { return }
            self._queue.async {
                if let successResult = result {
                    self._log("Task \(key) finished successfully")
                    // cache the result
                    self._cache.setObject(RequestManager.CacheObject(item: successResult), forKey: key as NSString)
                } else {
                    self._log("Task \(key) failed")
                }
                // remove from inflight:
                self._inflight.removeValue(forKey: key)
                self._remainingPoints += loadable.points.rawValue
                // send callbacks:
                for loadable in Array(self._pending) {
                    if loadable.key == key {
                        // remove from pending:
                        self._pending.remove(loadable)
                        loadable._callCompletionIfNeeded(result: result, err: err)
                    }
                }
                self._startPendingLoadablesIfAppropriate()
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
    func load(_ loadable: Loadable) {
        _queue.async {
            guard !self._pending.contains(loadable) else { return }
            print("Received loadable: \(loadable.key)")
            if let cached = self._cache.object(forKey: loadable.key as NSString) {
                print("   ✨ serving from cache")
                loadable._callCompletionIfNeeded(result: cached.item, err: nil)
                return
            }
            // add it to pending:
            self._pending.insert(loadable)
            if loadable.alreadyInflight {
                if self._inflight[loadable.key] == nil {
                    self._kickOff(loadable: loadable)
                }
                return
            }
            self._startPendingLoadablesIfAppropriate()
        }
    }
    func cancel(_ loadable: Loadable) {
        _queue.async {
            self._pending.remove(loadable)
        }
    }
}

class Loadable : Hashable, Equatable {
    init(key: String, points: RequestManager.Points, priority: RequestManager.Priority, load: @escaping (@escaping Completion) -> (), alreadyInflight: Bool, completionQueue: DispatchQueue, completion: @escaping Completion) {
        self.key = key
        self.points = points
        self.priority = priority
        self.load = load
        self.alreadyInflight = alreadyInflight
        self.completion = completion
        self.completionQueue = completionQueue
    }
    
    typealias Completion = ((Any?, Error?) -> ())
    
    let key: String
    let points: RequestManager.Points
    let priority: RequestManager.Priority
    let load: ((@escaping Completion) -> ()) // called on an arbitrary queue
    let alreadyInflight: Bool
    let completion: Completion
    let completionQueue: DispatchQueue
    var _calledYet = false
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    static func == (lhs: Loadable, rhs: Loadable) -> Bool {
        return lhs === rhs
    }
    
    func _callCompletionIfNeeded(result: Any?, err: Error?) {
        guard !_calledYet else { return }
        _calledYet = true
        completionQueue.async {
            self.completion(result, err)
        }
    }
}

class LoadableDisposer {
    let requestManager: RequestManager
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
    convenience init() {
        self.init(requestManager: RequestManager.shared)
    }
    var loadable: Loadable? {
        didSet(oldOpt) {
            if let newLoadable = loadable {
                RequestManager.shared.load(newLoadable)
            }
            if let old = oldOpt {
                RequestManager.shared.cancel(old)
            }
        }
    }
    deinit {
        if let old = loadable {
            RequestManager.shared.cancel(old)
        }
    }
}
