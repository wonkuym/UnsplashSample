//
//  PhotoCell.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import UIKit

class PhotoCell: UITableViewCell, ImageLoader {
    @IBOutlet weak var photoView: UIImageView!

    var pendingRequest: Request<Data>?
    
    var photo: UnsplashPhoto? {
        didSet {
            loadImage(to: photoView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelPendingRequest()
        photoView.image = nil
    }
}
