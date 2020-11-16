//
//  PhotosLoadStategy.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/19.
//

import Foundation

protocol PhotosLoadStategy {
    typealias Results = (photos: [UnsplashPhoto], isReachedEnd: Bool)
    
    func loadNext(_ completion: @escaping (Results?, Error?) -> Void)
}

class PhotosStategy: PhotosLoadStategy {
    private var page: Pagination
    
    init() {
        page = Pagination.firstPage(parameters: ["order_by": "popular"])
    }
    
    func loadNext(_ completion: @escaping (Results?, Error?) -> Void) {
        let photosRequest = UnsplashAPI.shared.photos(page)

        photosRequest.execute { [weak self] newPhotos in
            guard let self = self else { return }
            
            completion((photos: newPhotos, isReachedEnd: newPhotos.isEmpty), nil)
            
            self.page = self.page.nextPage()
        } failure: { error in
            completion(nil, error)
        }

        debugPrint("load next page: \(photosRequest.delegate.urlStringWithQuery)")
    }
}

class PhotosSearchStategy: PhotosLoadStategy {
    private var page: Pagination
    
    init(query: String) {
        page = Pagination.firstPage(parameters: ["query": query])
    }
    
    func loadNext(_ completion: @escaping (Results?, Error?) -> Void) {
        let photosRequest = UnsplashAPI.shared.searchPhoto(page)

        photosRequest.execute { [weak self] searchResults in
            guard let self = self else { return }
            
            let isReachedEnd = searchResults.totalPages == self.page.page
            completion((photos: searchResults.results, isReachedEnd: isReachedEnd), nil)
            
            self.page = self.page.nextPage()
        } failure: { error in
            completion(nil, error)
        }

        debugPrint("load next page: \(photosRequest.delegate.urlStringWithQuery)")
    }
}
