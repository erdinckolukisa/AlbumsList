//
//  AlbumsViewController.swift

import UIKit

class AlbumsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var mbid: String?
    var albumsViewModel: AlbumsViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.title = "Top Albums".localizedString
        configureCollectionView()
        bind()
    }
    
    private func configureCollectionView() {
        let nib = UINib(nibName: ConstantValues.albumCellNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ConstantValues.albumCellIdentifier)
    }
    
    private func bind() {
        guard let artistId = mbid else { return }
        // - StubApi() can be injected instead of WebApi() without changing anything else in the code
        albumsViewModel = AlbumsViewModel(networking: WebApi())
        albumsViewModel.getAlbums(mbid: artistId)
        albumsViewModel.delegate = self
    }
}

// MARK: - CollectionView implementations
extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsViewModel.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (collectionView.frame.width - 10)/2
        return CGSize(width: width, height: width + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConstantValues.albumCellIdentifier, for: indexPath) as? AlbumsCollectionViewCell {
            cell.configure(albumsCellViewModel: albumsViewModel.albums[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if albumsViewModel.albums.count > indexPath.row {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: ConstantValues.albumDetailViewController) as? AlbumDetailViewController  else { return }
            vc.mbid = albumsViewModel.albums[indexPath.row].mbid
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - AlbumsViewModelProtocol implementations
extension AlbumsViewController: AlbumsViewModelProtocol {
    func albumsDidUpdate() {
        collectionView.reloadData()
    }
    
    func errorDidUpdate(error: Error?) {
        showCustomMessageAlert(message: (error as? CustomError)?.localizedDescription ?? "An error occured. Please try again later", title: "Error") {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
