//
//  ArtistsTableViewController.swift

import UIKit

class ArtistsTableViewController: UITableViewController {
    var artistsViewModel: ArtistsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: ConstantValues.artistCellNibName, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: ConstantValues.artistCellIdentifier)
        bind()
    }
    
    func bind() {
        // - StubApi() can be injected instead of WebApi() without changing anything else in the code
        artistsViewModel = ArtistsViewModel(networking: WebApi())
        artistsViewModel.delegate = self
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistsViewModel.artists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ConstantValues.artistCellIdentifier, for: indexPath) as? ArtistTableViewCell {
            cell.configure(artistCellViewModel: artistsViewModel.artists[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: ConstantValues.albumsViewControllerIdentifier) as? AlbumsViewController else { return }
        if artistsViewModel.artists.count > indexPath.row  {
            let mbid = artistsViewModel.artists[indexPath.row].mbid
            vc.mbid = mbid
            self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating and UISearchBarDelegate
extension ArtistsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        artistsViewModel.searchArtist(name: searchController.searchBar.text)
    }
}

// MARK: - ArtistsViewModelProtocol
extension ArtistsTableViewController: ArtistsViewModelProtocol {
    func artistsDidUpdate() {
        tableView.reloadData()
    }
    
    func errorDidUpdate(error: Error?) {
        showCustomMessageAlert(message: (error as? CustomError)?.localizedDescription ?? "An error occured. Please try again later", title: "Error") {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
