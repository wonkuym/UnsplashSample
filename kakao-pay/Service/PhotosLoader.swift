//
//  PhotosLoader.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import Foundation

private let loadNextThreshold = 3

protocol PhotosLoadStategy {
    typealias PhotosLoadResult = Result<(photos: [UnsplashPhoto], isReachedEnd: Bool), Error>
    
    func loadNext(_ completion: @escaping (PhotosLoadResult) -> Void)
}

class PhotosLoader {
    var photos: [UnsplashPhoto]
    private var loadStategy: PhotosLoadStategy
    private var isReachedEnd: Bool
    private var isLoading: Bool
    
    convenience init() {
        self.init(loadStategy: PhotosListStategy())
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
    
    func loadNext(_ completion: @escaping (Result<[UnsplashPhoto], Error>) -> Void = { _ in }) {
        guard !isLoading && !isReachedEnd else { return }
        
        isLoading = true
        loadStategy.loadNext { [weak self] result in
            switch result {
            case .success(let data):
                self?.photos.append(contentsOf: data.photos)
                self?.isReachedEnd = data.isReachedEnd
                NotificationCenter.default.post(name: PhotosLoader.didLoadNewPhotosNotification, object: nil)
                completion(.success(data.photos))
            case .failure(let error):
                completion(.failure(error))
            }
            
            self?.isLoading = false
        }
    }
    
    func loadNextIfNeeded(reachedIndex: Int) {
        if photos.count - reachedIndex < loadNextThreshold {
            loadNext()
        }
    }
}
