//
//  ImageCache.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/18.
//

import UIKit

let MB = 1024 * 1024

class ImageCache {
    static let shared = ImageCache()
    
    lazy var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 30 * MB
        return cache
    }()
}
