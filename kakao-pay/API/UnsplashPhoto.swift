//
//  UnsplashPhoto.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import Foundation

struct UnsplashPhoto: Codable, Equatable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let urls: UnsplashPhotoUrls
    let user: UnsplashUser
    
    static func == (lhs: UnsplashPhoto, rhs: UnsplashPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UnsplashPhotoUrls: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashUser: Codable {
    let id: String
    let name: String
}
