//
//  PhotosLoadStategy.swift
//  UnsplashSample
//
//  Created by wonkyum kim on 2020/11/19.
//

import Foundation

class PhotosListStategy: PhotosLoadStategy {
    private var page: Pagination
    
    init() {
        page = Pagination.firstPage()
    }
    
    func loadNext(_ completion: @escaping (PhotosLoadResult) -> Void) {
        let photosRequest = UnsplashAPI.shared.photos(page)
        
        photosRequest.execute { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let newPhotos):
                completion(.success((photos: newPhotos, isReachedEnd: newPhotos.isEmpty)))
                self.page = self.page.nextPage()
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        debugPrint("load next page: \(photosRequest.urlStringWithQuery)")
    }
}

class PhotosSearchStategy: PhotosLoadStategy {
    private var page: Pagination
    
    init(query: String) {
        page = Pagination.firstPage(parameters: ["query": query])
    }
    
    func loadNext(_ completion: @escaping (PhotosLoadResult) -> Void) {
        let photosRequest = UnsplashAPI.shared.searchPhotos(page)
        
        photosRequest.execute { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let searchResults):
                let isReachedEnd = searchResults.totalPages == self.page.page
                completion(.success((photos: searchResults.results, isReachedEnd: isReachedEnd)))
                
                self.page = self.page.nextPage()
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        debugPrint("load next page: \(photosRequest.urlStringWithQuery)")
    }
}
