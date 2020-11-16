//
//  UnsplashSearchResults.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/18.
//

import Foundation

struct UnsplashSearchResults: Codable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]
}
