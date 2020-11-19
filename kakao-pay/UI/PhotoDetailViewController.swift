//
//  PhotoDetailViewController.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import UIKit

private let cellReuseIdentifier = "PhotoDetailCell"

struct DetailEnterContext {
    let photosLoader: PhotosLoader
    let selectedIndex: Int
    let closeHandler: (Int) -> Void
}

class PhotoDetailViewController: UICollectionViewController {
    
    var enterContext: DetailEnterContext?
    private var photos: [UnsplashPhoto] { enterContext?.photosLoader.photos ?? [] }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidLoad(_:)),
            name: PhotosLoader.didLoadNewPhotosNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = enterContext?.selectedIndex {
            let selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    @objc func photosDidLoad(_ notification: Notification) {
        collectionView.reloadData()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if  let closeHandler = enterContext?.closeHandler,
            let currentIndexPath = collectionView.indexPathsForVisibleItems.first {
            closeHandler(currentIndexPath.row)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastCell = collectionView.visibleCells.last,
              let lastCellIndexPath = collectionView.indexPath(for: lastCell) else {
            return
        }
        
        enterContext?.photosLoader.loadNextIfNeeded(reachedIndex: lastCellIndexPath.row)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let photo = photos[indexPath.row]
        
        if let cell = cell as? PhotoDetailCell {
            cell.photo = photo
        }
        
        return cell
    }
}

extension PhotoDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // the item height must be less than the height of the UICollectionView minus the section insets top and bottom values, minus the content insets top and bottom values.
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height - 300)
    }
}
