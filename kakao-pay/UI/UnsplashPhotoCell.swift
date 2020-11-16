//
//  UnsplashPhotoCell.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import UIKit

class UnsplashPhotoCell: UITableViewCell, PhotoCell {
    @IBOutlet weak var photoView: UIImageView!

    var pendingRequest: Request?
    
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
