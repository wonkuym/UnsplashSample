//
//  PhotoCell.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/18.
//

import UIKit

protocol PhotoCell: AnyObject {
    var photo: UnsplashPhoto? { get }
    var pendingRequest: Request? { get set }
}

extension PhotoCell {
    func loadImage(to imageView: UIImageView) {
        guard let photo = photo else { return }
        
        if let cachedImage = ImageCache.shared.cache.object(forKey: photo.urlString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        let photoRequest = Request(urlString: photo.urlString)
        photoRequest.execute { data in
            if let image = UIImage(data: data) {
                ImageCache.shared.cache.setObject(image, forKey: photo.urlString as NSString)
                imageView.image = image
            }
        } finally: { [weak self] in
            self?.pendingRequest = nil
        }
        pendingRequest = photoRequest
    }
    
    func cancelPendingRequest() {
        pendingRequest?.cancel()
        pendingRequest = nil
    }
}


fileprivate extension UnsplashPhoto {
    var urlString: String {
        return urls.small
    }
}
