//
//  PhotoSearchResultsViewController.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/18.
//

import UIKit

private let cellReuseIdentifier = "PhotoCell"
private let emptyCellReuseIdentifier = "PhotoSearchResultsEmptyCell"
private let recentQueryCellReuseIdentifier = "PhotoSearchResultsRecentQueryCell"

class PhotoSearchResultsViewController: UITableViewController, PhotoDetailPresentable {
    enum Status {
        case recentQueries
        case searchResults
        case emptySearchResults
    }
    
    var status: Status {
        if !loadedSearchResults {
            return .recentQueries
        }
        return photos.isEmpty ? .emptySearchResults : .searchResults
    }
    
    weak var searchController: UISearchController?
    var recentQueries: [String] = []
    var photos: [UnsplashPhoto] { photosLoader?.photos ?? [] }
    var photosLoader: PhotosLoader? {
        didSet {
            loadNext()
        }
    }
    var loadedSearchResults: Bool = false
    
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
        tableView.register(UINib(nibName: emptyCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellReuseIdentifier)
        tableView.register(UINib(nibName: recentQueryCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: recentQueryCellReuseIdentifier)
        tableView.separatorColor = .white
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
    
    func clearSearchResults() {
        photosLoader = nil
        loadedSearchResults = false
        tableView.reloadData()
    }
    
    func searchPhotos(_ query: String) {
        photosLoader = PhotosLoader(query: query)
        RecentSearchQuery.shared.addQeury(query)
    }
    
    func loadNext() {
        guard let photosLoader = photosLoader else { return }
        
        photosLoader.loadNext { [weak self] in
            self?.loadedSearchResults = true
            self?.tableView.reloadData()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard status == .searchResults,
              let lastCell = tableView.visibleCells.last,
              let lastCellIndexPath = tableView.indexPath(for: lastCell) else {
            return
        }
        
        photosLoader?.loadNextIfNeeded(reachedIndex: lastCellIndexPath.row)
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch status {
        case .recentQueries:
            return recentQueries.count
        case .searchResults:
            return photos.count
        case .emptySearchResults:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch status {
        case .recentQueries:
            let cell = tableView.dequeueReusableCell(withIdentifier: recentQueryCellReuseIdentifier, for: indexPath)
            
            if let recentCell = cell as? PhotoSearchResultsRecentQueryCell {
                let recentQuery = recentQueries[indexPath.row]
                recentCell.textLabel?.text = recentQuery
            }
            
            return cell
        case .searchResults:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
            
            if let photoCell = cell as? PhotoCell {
                let photo = photos[indexPath.row]
                photoCell.photo = photo
            }
            
            return cell
        case .emptySearchResults:
            return tableView.dequeueReusableCell(withIdentifier: emptyCellReuseIdentifier, for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch status {
        case .recentQueries:
            return 44
        case .searchResults:
            let photo = photos[indexPath.row]
            return tableView.frame.width * CGFloat(photo.height) / CGFloat(photo.width)
        case .emptySearchResults:
            return 300
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch status {
        case .recentQueries:
            let query = recentQueries[indexPath.row]
            
            if let searchController = searchController {
                searchController.searchBar.text = query
                searchController.searchBar.resignFirstResponder()
            }
            
            searchPhotos(query)
        case .searchResults:
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
        case .emptySearchResults:
            break
        }
    }
}
