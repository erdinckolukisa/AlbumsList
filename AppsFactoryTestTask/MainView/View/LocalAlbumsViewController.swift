//
//  MainViewController.swift

import UIKit

class LocalAlbumsViewController: UIViewController {
    
    var localAlbumsViewModel: LocalAlbumsViewModel!
    var artistsTableViewController: ArtistsTableViewController?
    var artistSearchController: UISearchController!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureCollectionView()
        localAlbumsViewModel = LocalAlbumsViewModel(persistable: RealmStorage())
        localAlbumsViewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        localAlbumsViewModel.getAlbums()
    }
    
    func configureCollectionView() {
        let nib = UINib(nibName: ConstantValues.albumCellNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ConstantValues.albumCellIdentifier)
    }
}

// MARK: - LocalAlbumsViewModelProtocol implementations
extension LocalAlbumsViewController: LocalAlbumsViewModelProtocol {
    func localAlbumsDidUpdate() {
        collectionView.reloadData()
    }
    
    func localAblumsErrorDidUpdate(error: Error?) {
        showCustomMessageAlert(message: (error as? CustomError)?.localizedDescription ?? "An error occured. Please try again later", title: "Error") {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
// MARK: - UICollectionView implementations
extension LocalAlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localAlbumsViewModel.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConstantValues.albumCellIdentifier, for: indexPath) as? AlbumsCollectionViewCell {
            cell.configureWithLocalData(localAlbumCellViewModel: localAlbumsViewModel.albums[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (collectionView.frame.width - 10) / 2
        return CGSize(width: width, height: width + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: ConstantValues.albumDetailViewController) as? AlbumDetailViewController else { return }
        if localAlbumsViewModel.albums.count > indexPath.row  {
            let mbid = localAlbumsViewModel.albums[indexPath.row].mbid
            vc.mbid = mbid
            vc.workFromPersistantStorage = true
            if let navigator = navigationController {
                navigator.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - UISearchControllerDelegate
extension LocalAlbumsViewController: UISearchControllerDelegate {
    func configureSearchBar() {
        artistsTableViewController =  storyboard?.instantiateViewController(withIdentifier: ConstantValues.artistsTableViewControllerIdentifier) as? ArtistsTableViewController
        artistSearchController = UISearchController(searchResultsController: artistsTableViewController)
        artistSearchController.delegate = self
        artistSearchController.searchResultsUpdater = artistsTableViewController
        artistSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        artistSearchController.loadViewIfNeeded()
        artistSearchController.searchBar.delegate = artistsTableViewController
        artistSearchController.hidesNavigationBarDuringPresentation = false
        artistSearchController.searchBar.placeholder = "Search for artists..."
        artistSearchController.searchBar.sizeToFit()
        artistSearchController.searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        artistSearchController.searchBar.tintColor = self.view.tintColor
        navigationItem.titleView = artistSearchController.searchBar
    }
}
