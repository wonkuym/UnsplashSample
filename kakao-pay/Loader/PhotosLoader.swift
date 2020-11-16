//
//  PhotosLoader.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import Foundation

class PhotosLoader {
    var photos: [UnsplashPhoto]
    private var loadStategy: PhotosLoadStategy
    private var isReachedEnd: Bool
    private var isLoading: Bool
    
    convenience init() {
        self.init(loadStategy: PhotosStategy())
    }
    
    convenience init(query: String) {
        self.init(loadStategy: PhotosSearchStategy(query: query))
    }
    
    private init(loadStategy: PhotosLoadStategy) {
        self.photos = []
        self.loadStategy = loadStategy
        self.isReachedEnd = false
        self.isLoading = false
    }
    
    func loadNext(_ completion: @escaping () -> Void = {}) {
        guard !isLoading && !isReachedEnd else { return }
        
        isLoading = true
        loadStategy.loadNext { [weak self] (results, error) in
            if let results = results {
                self?.photos.append(contentsOf: results.photos)
                self?.isReachedEnd = results.isReachedEnd
                NotificationCenter.default.post(name: PhotosLoader.didLoadNewPhotosNotification, object: nil)
            }
            self?.isLoading = false
            
            completion()
        }
    }
}
