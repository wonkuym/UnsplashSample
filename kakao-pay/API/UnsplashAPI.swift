//
//  UnsplashAPI.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import Foundation

class UnsplashAPI {
    static let shared = UnsplashAPI()
    
    let baseUrlString = "https://api.unsplash.com"
    
    // https://unsplash.com/documentation#photos
    func photos(_ pagination: Pagination) -> JSONRequest<[UnsplashPhoto]> {
        return makeRequest("/photos", parameters: pagination.toAllParameters())
    }
    
    // https://unsplash.com/documentation#search-photos
    func searchPhoto(_ pagination: Pagination) -> JSONRequest<UnsplashSearchResults> {
        return makeRequest("/search/photos", parameters: pagination.toAllParameters())
    }
    
    private func makeRequest<T: Codable>(_ path: String, parameters: [String: Any]) -> JSONRequest<T> {
        let urlString = "\(baseUrlString)\(path)"
        
        let headers: [String: String] = [
            "Authorization": "Client-ID EPmrvI5d1ijfTL_TqAkYgItzMxxErflorkC933VhL2Q"
        ]
        
        return JSONRequest(Request(urlString: urlString, parameters: parameters, headers: headers))
    }
}