//
//  PhotosViewController.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import UIKit

private let cellReuseIdentifier = "PhotoCell"

class PhotosViewController: UITableViewController {
    
    lazy var searchResultsController: PhotoSearchResultsController = {
        let searchResultsController = PhotoSearchResultsController()
        
        searchResultsController.photoSelectHandler = { [weak self] enterContext in
            self?.showDetail(enterContext)
        }
        
        return searchResultsController
    }()
    
    var photos: [UnsplashPhoto] { photosLoader.photos }
    var photosLoader: PhotosLoader = PhotosLoader()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchController()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidLoad(_:)),
            name: PhotosLoader.didLoadNewPhotosNotification,
            object: nil
        )
        
        photosLoader.loadNext()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorColor = .white
        tableView.separatorStyle = .singleLine
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search photos"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    @objc func photosDidLoad(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func showDetail(_ enterContext: DetailEnterContext) {
        performSegue(withIdentifier: "detailSegue", sender: enterContext)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UINavigationController,
           let detailVC = vc.viewControllers.first as? PhotoDetailViewController,
           let enterContext = sender as? DetailEnterContext {
            vc.modalPresentationStyle = .overFullScreen
            detailVC.enterContext = enterContext
        }
    }
    
    private func scrollToRow(_ row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastCell = tableView.visibleCells.last,
              let lastCellIndexPath = tableView.indexPath(for: lastCell) else {
            return
        }
        
        photosLoader.loadNextIfNeeded(reachedIndex: lastCellIndexPath.row)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
        showDetail(
            DetailEnterContext(
                photosLoader: photosLoader,
                selectedIndex: indexPath.row,
                closeHandler: { [weak self] currentIndex in
                    self?.scrollToRow(currentIndex)
                }
            )
        )
    }
}

// MARK: - UISearchBarDelegate Delegate
extension PhotosViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.count > 0 else { return }
        searchResultsController.photosLoader = PhotosLoader(query: query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResultsController.photosLoader = nil
    }
}
