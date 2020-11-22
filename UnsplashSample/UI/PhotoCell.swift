//
//  PhotoCell.swift
//  UnsplashSample
//
//  Created by wonkyum kim on 2020/11/17.
//

import UIKit

class PhotoCell: UITableViewCell, ImageLoader {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var pendingRequest: Request<Data>?
    
    var photo: UnsplashPhoto? {
        didSet {
            loadImage(to: photoView)
            userNameLabel.text = photo?.user.name
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelPendingRequest()
        photoView.image = nil
    }
}
