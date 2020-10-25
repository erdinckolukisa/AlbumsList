//
//  AlbumsViewModel.swift

import Foundation

protocol AlbumsViewModelProtocol: class {
    func albumsDidUpdate()
    func errorDidUpdate(error: Error?)
}

class AlbumsViewModel {
    var networking: Networkable
    var albums = [AlbumsCellViewModel]()
    weak var delegate: AlbumsViewModelProtocol?
    init(networking: Networkable) {
        self.networking = networking
    }
    
    func getAlbums(mbid: String) {
        networking.getTopAlbums(artistId: mbid) { [weak self] topAlbums, error in
            if error != nil {
                self?.delegate?.errorDidUpdate(error: error)
                return
            }
            
            self?.albums = topAlbums?.album?.compactMap { AlbumsCellViewModel(album: $0)} ?? []
            self?.delegate?.albumsDidUpdate()
        }
    }
}
