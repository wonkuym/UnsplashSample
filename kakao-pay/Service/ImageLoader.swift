//
//  ImageLoader.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/18.
//

import UIKit

protocol ImageLoader: AnyObject {
    var photo: UnsplashPhoto? { get }
    var pendingRequest: Request<Data>? { get set }
}

extension ImageLoader {
    func loadImage(to imageView: UIImageView) {
        guard let photo = photo else { return }
        
        if let cachedImage = ImageCache.shared.cache.object(forKey: photo.urlString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        let photoRequest = Request<Data>(urlString: photo.urlString, mapper: { data in data})
        photoRequest.execute { [weak self] result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    ImageCache.shared.cache.setObject(image, forKey: photo.urlString as NSString)
                    imageView.image = image
                }
            case .failure(let error):
                debugPrint(error)
            }
            
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
