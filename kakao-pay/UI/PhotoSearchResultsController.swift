//
//  PhotoSearchResultsController.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/18.
//

import UIKit

private let cellReuseIdentifier = "PhotoCell"

class PhotoSearchResultsController: UITableViewController, PhotoDetailPresentable {
    var photos: [UnsplashPhoto] { photosLoader?.photos ?? [] }
    
    var photosLoader: PhotosLoader? {
        didSet {
            tableView.reloadData()
            loadNext()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNotificationCenter()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorColor = .white
        tableView.separatorStyle = .singleLine
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidLoad(_:)),
            name: PhotosLoader.didLoadNewPhotosNotification,
            object: nil
        )
    }
    
    @objc func photosDidLoad(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func loadNext() {
        guard let photosLoader = photosLoader else { return }
        photosLoader.loadNext { [weak self] in self?.tableView.reloadData() }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastCell = tableView.visibleCells.last,
              let lastCellIndexPath = tableView.indexPath(for: lastCell) else {
            return
        }
        
        photosLoader?.loadNextIfNeeded(reachedIndex: lastCellIndexPath.row)
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let photo = photos[indexPath.row]
        
        if let photoCell = cell as? PhotoCell {
            photoCell.photo = photo
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        return tableView.frame.width * CGFloat(photo.height) / CGFloat(photo.width)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let photosLoader = photosLoader else { return }
        
        let enterContext = DetailEnterContext(
            photosLoader: photosLoader,
            selectedIndex: indexPath.row,
            closeHandler: { [weak self] currentIndex in
                let indexPath = IndexPath(row: currentIndex, section: 0)
                self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            }
        )
        
        showDetail(enterContext)
    }
}
