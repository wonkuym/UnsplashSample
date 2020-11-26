//
//  PagedLoader+UnsplashPhoto.swift
//  UnsplashSample
//
//  Created by wonkyum kim on 2020/11/26.
//

import Foundation

extension PagedLoader where ItemType == UnsplashPhoto {
    static func newPhotosLoader() -> PagedLoader<ItemType> {
        let firstPage = Pagination.firstPage()
        
        return PagedLoader(firstPage) { page, completion in
            let photosRequest = UnsplashAPI.shared.photos(page)
            
            photosRequest.execute { result in
                switch result {
                case .success(let newPhotos):
                    completion(.success((newItems: newPhotos, isReachedEnd: newPhotos.isEmpty)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            debugPrint("load next page: \(photosRequest.urlStringWithQuery)")
        }
    }
    
    static func newPhotosSearchLoader(query: String) -> PagedLoader<ItemType> {
        let firstPage = Pagination.firstPage(parameters: ["query": query])
        
        return PagedLoader(firstPage) { page, completion in
            let photosRequest = UnsplashAPI.shared.searchPhotos(page)
            
            photosRequest.execute { result in
                switch result {
                case .success(let searchResults):
                    let isReachedEnd = searchResults.totalPages == page.page
                    completion(.success((newItems: searchResults.results, isReachedEnd: isReachedEnd)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            debugPrint("load next page: \(photosRequest.urlStringWithQuery)")
        }
    }
}
