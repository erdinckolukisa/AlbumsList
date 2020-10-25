//
//  AlbumsCellViewModel.swift

import Foundation

class AlbumsCellViewModel {
    var mbid: String?
    var albumName: String?
    var imageUrlString: String?
    
    init?(album: Album) {
        guard let albumName = album.name, let albumId = album.mbid else { return nil}
        self.mbid = albumId
        self.albumName = albumName
        self.imageUrlString = album.image?.last?.url
    }
}
