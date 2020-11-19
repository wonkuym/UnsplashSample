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
    var enterContext: DetailEnterContext? {
        didSet {
            needsScrollToInitialPhotoIndex = enterContext?.selectedIndex != nil
        }
    }
    var needsScrollToInitialPhotoIndex: Bool = false
    var initialPhotoIndexPath: IndexPath? {
        guard let selectedIndex = enterContext?.selectedIndex else { return nil }
        return IndexPath(row: selectedIndex, section: 0)
    }
    
    var photos: [UnsplashPhoto] { enterContext?.photosLoader.photos ?? [] }
    var panGestureInteractionController: PanGestureInteractionController?
    
    var currentPhotoImage: UIImage? {
        guard let currentCell = collectionView.visibleCells.first as? PhotoDetailCell else { return nil }
        return currentCell.photoView.image
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        modalPresentationCapturesStatusBarAppearance = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidLoad(_:)),
            name: PhotosLoader.didLoadNewPhotosNotification,
            object: nil
        )
        
        panGestureInteractionController = PanGestureInteractionController(viewController: self)
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsScrollToInitialPhotoIndex,
           let initialPhotoIndexPath = initialPhotoIndexPath {
            needsScrollToInitialPhotoIndex = false
            collectionView.scrollToItem(at: initialPhotoIndexPath,at: .centeredHorizontally, animated: false)
        }
    }
    
    @objc func photosDidLoad(_ notification: Notification) {
        collectionView.reloadData()
    }
    
    func handleEnterContextClose() {
        if  let closeHandler = enterContext?.closeHandler,
            let currentIndexPath = collectionView.indexPathsForVisibleItems.first {
            closeHandler(currentIndexPath.row)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastCell = collectionView.visibleCells.last,
              let lastCellIndexPath = collectionView.indexPath(for: lastCell) else {
            return
        }
        
        enterContext?.photosLoader.loadNextIfNeeded(reachedIndex: lastCellIndexPath.row)
    }
    
    // MARK: - UICollectionViewDataSource
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

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.safeAreaLayoutGuide.layoutFrame.size
    }
}
