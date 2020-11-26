//
//  PagedLoader.swift
//  UnsplashSample
//
//  Created by wonkyum kim on 2020/11/25.
//

import Foundation

let didLoadNewItemsNotification = Notification.Name(rawValue: "wk.notification.name.pagedLoader.didLoadNewItemsNotification")

class PagedLoader<ItemType> {
    typealias LoadResult = Result<(newItems: [ItemType], isReachedEnd: Bool), Error>
    typealias Fetcher = (Pagination, @escaping (LoadResult) -> Void) -> Void
    
    private var page: Pagination
    private let fetcher: Fetcher
    private let loadNextThreshold: Int = 3
    private(set) var items: [ItemType]
    private var isLoading: Bool
    private var isReachedEnd: Bool
    
    init(_ page: Pagination, fetcher: @escaping Fetcher) {
        self.page = page
        self.fetcher = fetcher
        self.items = []
        self.isLoading = false
        self.isReachedEnd = false
    }
    
    func loadNext(_ completion: ((Result<[ItemType], Error>) -> Void)? = nil) {
        guard !isLoading, !isReachedEnd else { return }
        
        isLoading = true
        fetcher(page) { [weak self] loadResult in
            guard let strongSelf = self else { return }
            
            switch loadResult {
            case .success((let newItems, let isReachedEnd)):
                strongSelf.items.append(contentsOf: newItems)
                strongSelf.isReachedEnd = isReachedEnd
                
                if let completion = completion {
                    completion(.success(newItems))
                }
                
                NotificationCenter.default.post(name: didLoadNewItemsNotification, object: nil)
            case .failure(let error):
                if let completion = completion {
                    completion(.failure(error))
                }
            }
            strongSelf.isLoading = false
        }
    }
    
    func loadNextIfNeeded(reachedIndex: Int) {
        if items.count - reachedIndex < loadNextThreshold {
            loadNext()
        }
    }
}
