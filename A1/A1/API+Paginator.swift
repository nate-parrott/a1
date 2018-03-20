//
//  API+Paginator.swift
//  A1
//
//  Created by Nate Parrott on 3/20/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation
import Firebase

extension API {
    class Paginator {
        init(query: Query) {
            self.query = query
            _newestDocListener = query.limit(to: 1).addSnapshotListener { [weak self] (snapshotOpt, _) in
                guard let snapshot = snapshotOpt else { return }
                self?._newestDocId = snapshot.documents.first?.documentID
                self?.onUpdate?()
            }
            refresh()
        }
        let query: Query
        var _newestDocListener: ListenerRegistration!
        
        deinit {
            _newestDocListener.remove()
        }
        
        var hasNew: Bool {
            guard let newestId = _newestDocId else { return false }
            guard let currentTopId = documents.first?.documentID else { return true }
            return currentTopId != newestId
        }
        var isLoading = false
        var canLoadMore = false
        var error = false
        var _newestDocId: String?
        var documents = [DocumentSnapshot]()
        var onUpdate: (() -> ())?
        
        let docsPerPage = 20
        
        func refresh() {
            guard !isLoading else { return }
            isLoading = true
            error = false
            canLoadMore = false
            documents = []
            onUpdate?()
            
            query.limit(to: docsPerPage + 1).getDocuments { (snapshotOpt, err) in
                guard let snapshot = snapshotOpt, err == nil else {
                    self.error = true
                    self.onUpdate?()
                    return
                }
                var newDocs: [DocumentSnapshot] = snapshot.documents
                if newDocs.count > self.docsPerPage {
                    self.canLoadMore = true
                    newDocs.removeLast()
                }
                self.documents = newDocs
                self.isLoading = false
                self.onUpdate?()
            }
        }
        
        func loadMore() {
            guard !isLoading && canLoadMore, let lastDoc = documents.last else { return }
            isLoading = true
            error = false
            canLoadMore = false
            onUpdate?()
            
            query.start(after: [lastDoc]).limit(to: docsPerPage + 1).getDocuments { (snapshotOpt, err) in
                guard let snapshot = snapshotOpt, err == nil else {
                    self.error = true
                    self.canLoadMore = true
                    self.onUpdate?()
                    return
                }
                var newDocs: [DocumentSnapshot] = snapshot.documents
                if newDocs.count > self.docsPerPage {
                    self.canLoadMore = true
                    newDocs.removeLast()
                }
                self.documents += newDocs
                self.isLoading = false
                self.onUpdate?()
            }
        }
    }
}
