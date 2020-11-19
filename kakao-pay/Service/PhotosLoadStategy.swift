//
//  PhotosLoadStategy.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/19.
//

import Foundation

class PhotosListStategy: PhotosLoadStategy {
    private var page: Pagination
    
    init() {
        page = Pagination.firstPage()
    }
    
    func loadNext(_ completion: @escaping (Results?, Error?) -> Void) {
        let photosRequest = UnsplashAPI.shared.photos(page)
        
        photosRequest.execute { [weak self] newPhotos, error in
            guard let self = self else { return }
            
            if let newPhotos = newPhotos {
                completion((photos: newPhotos, isReachedEnd: newPhotos.isEmpty), nil)
                self.page = self.page.nextPage()
            } else if let error = error {
                completion(nil, error)
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
    
    func loadNext(_ completion: @escaping (Results?, Error?) -> Void) {
        let photosRequest = UnsplashAPI.shared.searchPhoto(page)
        
        photosRequest.execute { [weak self] searchResults, error in
            guard let self = self else { return }
            
            if let searchResults = searchResults {
                let isReachedEnd = searchResults.totalPages == self.page.page
                completion((photos: searchResults.results, isReachedEnd: isReachedEnd), nil)
                
                self.page = self.page.nextPage()
            } else if let error = error {
                completion(nil, error)
            }
        }
        
        debugPrint("load next page: \(photosRequest.urlStringWithQuery)")
    }
}
