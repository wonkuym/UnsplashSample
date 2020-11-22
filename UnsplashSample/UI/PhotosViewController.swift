//
//  PhotosViewController.swift
//  UnsplashSample
//
//  Created by wonkyum kim on 2020/11/17.
//

import UIKit

private let cellReuseIdentifier = "PhotoCell"

class PhotosViewController: UITableViewController, PhotoDetailPresentable {
    
    lazy var searchResultsController = PhotoSearchResultsViewController()
    var photos: [UnsplashPhoto] { photosLoader.photos }
    var photosLoader: PhotosLoader = PhotosLoader()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchController()
        setupNotificationCenter()
        
        photosLoader.loadNext()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorColor = .white
        tableView.separatorStyle = .singleLine
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search photos"
        
        searchResultsController.searchController = searchController
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastCell = tableView.visibleCells.last,
              let lastCellIndexPath = tableView.indexPath(for: lastCell) else {
            return
        }
        
        photosLoader.loadNextIfNeeded(reachedIndex: lastCellIndexPath.row)
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

// MARK: - UISearchBarDelegate
extension PhotosViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.count > 0 else { return }
        searchResultsController.searchPhotos(query)
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchResultsController.recentQueries = RecentSearchQuery.shared.recentQueries
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchResultsController.clearSearchResults()
    }
}
