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

class PhotoDetailViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = view.frame.size
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        return titleLabel
    }()
    
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
        setupNotificationCenter()
        setupTopView()
        
        modalPresentationCapturesStatusBarAppearance = true
        panGestureInteractionController = PanGestureInteractionController(viewController: self)
        
        collectionView.reloadData()
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setupTopView() {
        let closeButton = UIButton.init(type: .system)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
        
        let topView = UIView()
        topView.backgroundColor = .clear
        topView.addSubview(closeButton)
        topView.addSubview(titleLabel)
        view.addSubview(topView)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 40),
            
            closeButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 8),
            closeButton.topAnchor.constraint(equalTo: topView.topAnchor),
            closeButton.heightAnchor.constraint(equalTo: topView.heightAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topView.topAnchor),
            titleLabel.heightAnchor.constraint(equalTo: topView.heightAnchor)
        ])
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidLoad(_:)),
            name: PhotosLoader.didLoadNewPhotosNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needsScrollToInitialPhotoIndex,
           let initialPhotoIndexPath = initialPhotoIndexPath {
            needsScrollToInitialPhotoIndex = false
            setTitleForPhoto(at: initialPhotoIndexPath)
            collectionView.scrollToItem(at: initialPhotoIndexPath,at: .centeredHorizontally, animated: false)
        }
    }
    
    @objc func photosDidLoad(_ notification: Notification) {
        collectionView.reloadData()
    }
    
    @objc func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleEnterContextClose() {
        if  let closeHandler = enterContext?.closeHandler,
            let currentIndexPath = collectionView.indexPathsForVisibleItems.first {
            closeHandler(currentIndexPath.row)
        }
    }
    
    func setTitleForPhoto(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        titleLabel.text = photo.user.name
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let photo = photos[indexPath.row]
        
        if let cell = cell as? PhotoDetailCell {
            cell.photo = photo
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let visibleIndexPath = collectionView.indexPathsForVisibleItems.last {
            setTitleForPhoto(at: visibleIndexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoDetailViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastCell = collectionView.visibleCells.last,
              let lastCellIndexPath = collectionView.indexPath(for: lastCell) else {
            return
        }
        
        enterContext?.photosLoader.loadNextIfNeeded(reachedIndex: lastCellIndexPath.row)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.safeAreaLayoutGuide.layoutFrame.size
    }
}
